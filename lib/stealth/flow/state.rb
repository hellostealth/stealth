# coding: utf-8
# frozen_string_literal: true

module Stealth
  module Flow
    class State

      include Comparable

      attr_accessor :name
      attr_reader :spec, :fails_to

      def initialize(name, spec, fails_to = nil)
        if fails_to.present? && !fails_to.is_a?(Stealth::Flow::State)
          raise(ArgumentError, 'fails_to state should be a Stealth::Flow::State')
        end

        @name, @spec, @fails_to = name, spec, fails_to
      end

      def <=>(other_state)
        states = spec.states.keys

        unless states.include?(other_state.to_sym)
          raise(ArgumentError, "state `#{other_state}' does not exist")
        end

        states.index(self.to_sym) <=> states.index(other_state.to_sym)
      end

      def to_s
        "#{name}"
      end

      def to_sym
        name.to_sym
      end
    end
  end
end
