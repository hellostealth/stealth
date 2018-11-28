# coding: utf-8
# frozen_string_literal: true

module Stealth
  class Session

    SLUG_SEPARATOR = '->'

    attr_reader :flow, :state, :user_id, :previous
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

    def self.flow_and_state_from_session_slug(slug:)
      {
        flow: slug&.split(SLUG_SEPARATOR)&.first,
        state: slug&.split(SLUG_SEPARATOR)&.last
      }
    end

    def flow
      return nil if flow_string.blank?

      @flow ||= FlowMap.new.init(flow: flow_string, state: state_string)
    end

    def state
      flow&.current_state
    end

    def flow_string
      session&.split(SLUG_SEPARATOR)&.first
    end

    def state_string
      session&.split(SLUG_SEPARATOR)&.last
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

    def set(flow:, state:)
      store_current_to_previous(flow: flow, state: state)

      @flow = nil
      @session = self.class.canonical_session_slug(flow: flow, state: state)

      Stealth::Logger.l(topic: "session", message: "User #{user_id}: setting session to #{flow}->#{state}")

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
      new_session.session = self.class.canonical_session_slug(flow: self.flow_string, state: new_state)

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
      session_regex = /(.+)(#{SLUG_SEPARATOR})(.+)/
      !!string.match(session_regex)
    end

    def self.canonical_session_slug(flow:, state:)
      [flow, state].join(SLUG_SEPARATOR)
    end

    private

      def previous_session_key(user_id:)
        [user_id, 'previous'].join('-')
      end

      def store_current_to_previous(flow:, state:)
        new_session = self.class.canonical_session_slug(flow: flow, state: state)

        # Prevent previous_session from becoming current_session
        if new_session == session
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
        end
      end

  end
end
