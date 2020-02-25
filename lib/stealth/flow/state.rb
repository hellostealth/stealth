# coding: utf-8
# frozen_string_literal: true

module Stealth
  module Flow
    class State

      include Comparable

      attr_accessor :name
      attr_reader :spec, :fails_to, :redirects_to, :opts

      def initialize(name:, spec:, fails_to: nil, redirects_to: nil, opts:)
        if fails_to.present? && !fails_to.is_a?(Stealth::Session)
          raise(ArgumentError, 'fails_to state should be a Stealth::Session')
        end

        if redirects_to.present? && !redirects_to.is_a?(Stealth::Session)
          raise(ArgumentError, 'redirects_to state should be a Stealth::Session')
        end

        @name, @spec = name, spec
        @fails_to, @redirects_to, @opts = fails_to, redirects_to, opts
      end

      def <=>(other_state)
        state_position(self) <=> state_position(other_state)
      end

      def +(steps)
        if steps < 0
          new_position = state_position(self) + steps

          # we don't want to allow the array index to wrap here so we return
          # the first state instead
          if new_position < 0
            new_state = spec.states.keys.first
          else
            new_state = spec.states.keys.at(new_position)
          end
        else
          new_state = spec.states.keys[state_position(self) + steps]

          # we may have been told to access an out-of-bounds state
          # return the last state
          if new_state.blank?
            new_state = spec.states.keys.last
          end
        end

        new_state
      end

      def -(steps)
        if steps < 0
          return self + steps.abs
        else
          return self + (-steps)
        end
      end

      def to_s
        "#{name}"
      end

      def to_sym
        name.to_sym
      end

      private

        def state_position(state)
          states = spec.states.keys

          unless states.include?(state.to_sym)
            raise(ArgumentError, "state `#{state}' does not exist")
          end

          states.index(state.to_sym)
        end
    end
  end
end
