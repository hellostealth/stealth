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
        unless defined?(Stealth::RedisSupport) && Stealth::RedisSupport.connection_pool.present?
          raise(
            Stealth::Errors::RedisNotConfigured,
            "Please make sure STEALTH_REDIS_URL or REDIS_URL is configured before using sessions"
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

    def flow
      return nil if flow_string.blank?
      return nil unless Stealth::FlowManager.instance.flow_exists?(flow_string.to_sym)

      @flow ||= Stealth::FlowManager.instance.instance_variable_get(:@flows)[flow_string.to_sym]
    end

    def state
      return nil if flow.blank? || state_string.blank?

      state_symbol = state_string.to_sym
      return state_symbol if flow[:states].key?(state_symbol)

      nil
    end

    def current_state
      Stealth::FlowManager.instance.current_state(self)
    end

    # Returns a new session pointing to the `fails_to` state if defined
    def fails_to
      return nil unless current_state&.dig(:options, :fails_to)
      new_session = Stealth::Session.new(id: id)
      new_session.session = self.class.canonical_session_slug(
        flow: flow_string,
        state: current_state.dig(:options, :fails_to).to_s
      )
      new_session
    end

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
      Stealth::RedisSupport.with { |r| r.del(session_key) }
    end

    def present?
      session.present?
    end

    def blank?
      !present?
    end

    def +(steps)
      return nil if flow.blank? || state.blank?
      return self if steps.zero?

      states = flow.keys # Get all states in order
      current_index = states.index(state)
      return self unless current_index

      new_index = current_index + steps
      new_index = 0 if new_index.negative? # Ensure it doesn't go below the first state
      return self if new_index >= states.size

      new_state = states[new_index]
      new_session = Stealth::Session.new(id: id)
      new_session.session = self.class.canonical_session_slug(flow: flow_string, state: new_state)

      new_session
    end

    def -(steps)
      self + (-steps)
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
