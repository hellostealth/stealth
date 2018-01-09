# coding: utf-8
# frozen_string_literal: true

module Stealth
  class Session

    SLUG_SEPARATOR = '->'

    attr_reader :flow, :state, :user_id
    attr_accessor :session

    def initialize(user_id:)
      @user_id = user_id

      unless defined?($redis) && $redis.present?
        raise(Stealth::Errors::RedisNotConfigured, "Please make sure REDIS_URL is configured before using sessions")
      end

      get
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

      @flow = begin
        flow_klass = [flow_string, 'flow'].join('_').classify.constantize
        flow = flow_klass.new.init_state(state_string)
        flow
      end
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
      @session ||= $redis.get(user_id)
    end

    def set(flow:, state:)
      @session = canonical_session_slug(flow: flow, state: state)
      flow
      $redis.set(user_id, session)
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
      new_session = Stealth::Session.new(user_id: self.user_id)
      new_session.session = canonical_session_slug(flow: self.flow_string, state: new_state)

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

    private

      def canonical_session_slug(flow:, state:)
        [flow, state].join(SLUG_SEPARATOR)
      end

  end
end
