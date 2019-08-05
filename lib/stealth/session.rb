# coding: utf-8
# frozen_string_literal: true

module Stealth
  class Session

    STATE_SEPARATOR = '->'
    PARAMS_SEPARATOR = '?'

    attr_reader :user_id, :previous
    attr_accessor :session

    def initialize(user_id: nil, previous: false)
      @user_id = user_id
      @previous = previous

      if user_id.present?
        unless defined?($redis) && $redis.present?
          raise(Stealth::Errors::RedisNotConfigured, "Please make sure REDIS_URL is configured before using sessions")
        end

        get
      end

      self
    end

    def flow
      return nil if flow_string.blank?

      @flow ||= FlowMap.new.init(flow: flow_string, state: state_string)
    end

    def state
      flow&.current_state
    end

    def params
      (params_json.blank? || params_json == "{}") ? {} : ActiveSupport::HashWithIndifferentAccess.new(JSON.load(params_json))
    end

    def flow_string
      session&.split(STATE_SEPARATOR)&.first
    end

    def state_string
      session&.split(STATE_SEPARATOR, 2)&.second&.split(PARAMS_SEPARATOR)&.first
    end

    def params_json
      session&.split(STATE_SEPARATOR, 2)&.second&.split(PARAMS_SEPARATOR, 2)&.second
    end

    def get
      prev_key = previous_session_key(user_id: user_id)

      @session ||= begin
        if sessions_expire?
          previous? ? getex(prev_key) : getex(user_id)
        else
          previous? ? $redis.get(prev_key) : $redis.get(user_id)
        end
      end
    end

    def set(flow:, state:, params:)
      store_current_to_previous(flow: flow, state: state, params: params)

      @flow = nil
      @session = self.class.canonical_session_slug(flow: flow, state: state, params: params)

      Stealth::Logger.l(topic: "session", message: "User #{user_id}: setting session to #{flow}->#{state}?#{params.to_h}")

      if sessions_expire?
        $redis.setex(user_id, Stealth.config.session_ttl, session)
      else
        $redis.set(user_id, session)
      end
    end

    def present?
      session.present?
    end

    def blank?
      !present?
    end

    def previous?
      @previous
    end

    def +(steps)
      return nil if flow.blank?
      return self if steps.zero?

      new_state = self.state + steps
      new_session = Stealth::Session.new(user_id: self.user_id)
      new_session.session = self.class.canonical_session_slug(flow: self.flow_string, state: new_state, params: {})

      new_session
    end

    def -(steps)
      return nil if flow.blank?

      if steps < 0
        return self + steps.abs
      else
        return self + (-steps)
      end
    end

    def self.is_a_session_string?(string)
      session_regex = /(.+)(#{STATE_SEPARATOR})(.+)/
      !!string.match(session_regex)
    end

    def self.canonical_session_slug(flow:, state:, params:)
      params_json_dump = params.blank? ? '{}' : JSON.dump(params.to_h)
      "#{flow.to_s}#{STATE_SEPARATOR}#{state.to_s}#{PARAMS_SEPARATOR}#{params_json_dump}"
    end

    private

      def previous_session_key(user_id:)
        [user_id, 'previous'].join('-')
      end

      def store_current_to_previous(flow:, state:, params:)
        new_session = self.class.canonical_session_slug(flow: flow, state: state, params: params)

        # Prevent previous_session from becoming current_session, exclude params
        if new_session&.split(PARAMS_SEPARATOR)&.first == session&.split(PARAMS_SEPARATOR)&.first
          Stealth::Logger.l(topic: "previous_session", message: "User #{user_id}: skipping setting to #{session} because it is the same as current_session")
        else
          Stealth::Logger.l(topic: "previous_session", message: "User #{user_id}: setting to #{session}")
          $redis.set(previous_session_key(user_id: user_id), session)
        end
      end

      def sessions_expire?
        Stealth.config.session_ttl > 0
      end

      def getex(key)
        $redis.multi do
          $redis.expire(key, Stealth.config.session_ttl)
          $redis.get(key)
        end.last
      end

  end
end
