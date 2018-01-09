# coding: utf-8
# frozen_string_literal: true

require 'stealth/flow/core_ext'
require 'stealth/flow/specification'
require 'stealth/flow/state'

module Stealth
  module Flow

    extend ActiveSupport::Concern

    class_methods do
      attr_reader :flow_spec

      def flow(&specification)
        @flow_spec = Specification.new(&specification)
      end
    end

    included do
      attr_accessor :flow_state, :user_id

      def current_state
        res = spec.states[@flow_state.to_sym] if @flow_state
        res || spec.initial_state
      end

      def spec
        # check the singleton class first
        class << self
          return flow_spec if flow_spec
        end

        self.class.flow_spec
      end

      def states
        self.spec.states.keys
      end

      def init_state(state)
        raise(ArgumentError, 'No state was specified.') if state.blank?

        new_state = state.to_sym
        unless states.include?(new_state)
          raise(Stealth::Errors::InvalidStateTransition)
        end
        @flow_state = new_state

        self
      end

      private

        def flow_and_state
          [self.class.to_s, current_state].join("->")
        end
    end

  end
end
