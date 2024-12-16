# coding: utf-8
# frozen_string_literal: true

module Stealth
  class Session

    include Stealth::Redis

    SLUG_SEPARATOR = '->'

    attr_reader :flow, :state, :id, :type
    attr_accessor :session, :locals, :before_update_session_to_locals

    # Session types:
    #   - :primary
    #   - :previous
    #   - :back_to
    def initialize(id: nil, type: :primary)
      @id = id
      @type = type

      if id.present?
        unless defined?($redis) && $redis.present?
          raise(
            Stealth::Errors::RedisNotConfigured,
            "Please make sure REDIS_URL is configured before using sessions"
          )
        end

        load_previous_locals
        load_before_update_session_to_locals
        get_session
      end

      self
    end

    def self.flow_and_state_from_session_slug(slug:)
      {
        flow: slug&.split(SLUG_SEPARATOR)&.first,
        state: slug&.split(SLUG_SEPARATOR)&.last
      }
    end

    def self.slugify(flow:, state:)
      unless flow.present? && state.present?
        raise(ArgumentError, 'A flow and state must be specified.')
      end

      [flow, state].join(SLUG_SEPARATOR)
    end

    # def flow
    #   return nil if flow_string.blank?

    #   @flow ||= FlowMap.new.init(flow: flow_string, state: state_string)
    # end

    # def state
    #   flow&.current_state
    # end

    def flow_string
      session&.split(SLUG_SEPARATOR)&.first
    end

    def state_string
      session&.split(SLUG_SEPARATOR)&.last
    end

    def load_previous_locals
      load_json_from_redis(previous_locals_key, :@locals)
    end

    def load_before_update_session_to_locals
      load_json_from_redis(before_update_session_to_locals_key, :@before_update_session_to_locals)
    end

    def load_json_from_redis(key, instance_variable_name)
      return if primary_session?

      value = get_key(key)

      if value.present? && value.is_a?(String)
        begin
          instance_variable_set(instance_variable_name, JSON.parse(value))
        rescue JSON::ParserError => e
          Stealth::Logger.l(
            topic: "session",
            message: "User #{id}: failed to parse locals from Redis -> #{value}, error: #{e.message}"
          )
        end
      end
    end

    def get_session
      @session ||= get_key(session_key)
    end

    def set_session(new_flow:, new_state:)
      @flow = nil # override @flow's memoization
      existing_session = session # tmp backup for previous_session storage
      @session = self.class.canonical_session_slug(
        flow: new_flow,
        state: new_state
      )

      Stealth::Logger.l(
        topic: [type, 'session'].join('_'),
        message: "User #{id}: setting session to #{new_flow}->#{new_state}"
      )

      if primary_session?
        store_current_to_previous(existing_session: existing_session)
      end

      persist_key(key: session_key, value: session)
    end

    def clear_session
      $redis.del(session_key)
    end

    def present?
      session.present?
    end

    def blank?
      !present?
    end

    def +(steps)
      return nil if flow.blank?
      return self if steps.zero?

      new_state = self.state + steps
      new_session = Stealth::Session.new(id: self.id)
      new_session.session = self.class.canonical_session_slug(
        flow: self.flow_string,
        state: new_state
      )

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

    def ==(other_session)
      self.flow_string == other_session.flow_string &&
        self.state_string == other_session.state_string &&
        self.type == other_session.type &&
        self.id == other_session.id
    end

    def self.is_a_session_string?(string)
      session_regex = /(.+)(#{SLUG_SEPARATOR})(.+)/
      !!string.match(session_regex)
    end

    def self.canonical_session_slug(flow:, state:)
      [flow, state].join(SLUG_SEPARATOR)
    end

    def session_key
      case type
      when :primary
        id
      when :previous
        previous_session_key
      when :back_to
        back_to_key
      end
    end

    def primary_session?
      type == :primary
    end

    def previous_session?
      type == :previous
    end

    def back_to_session?
      type == :back_to
    end

    def to_s
      [flow_string, state_string].join(SLUG_SEPARATOR)
    end

    private

      def previous_session_key
        [id, 'previous'].join('-')
      end

      def previous_locals_key
        [id, 'previous', 'locals'].join('-')
      end

      def before_update_session_to_locals_key
        [id, 'before_update_session_to', 'locals'].join('-')
      end

      def back_to_key
        [id, 'back_to'].join('-')
      end

      def store_current_to_previous(existing_session:)
        Stealth::Logger.l(
          topic: "previous_session",
          message: "User #{id}: setting to #{existing_session}"
        )

        persist_key(key: previous_session_key, value: existing_session)
        persist_key(key: previous_locals_key, value: @locals.to_json)
        persist_key(key: before_update_session_to_locals_key, value: @before_update_session_to_locals.to_json)
      end

  end
end
