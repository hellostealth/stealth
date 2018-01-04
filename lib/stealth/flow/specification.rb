# coding: utf-8
# frozen_string_literal: true

module Stealth
  module Flow
    class Specification
      attr_accessor :states, :initial_state

      def initialize(&specification)
        @states = Hash.new
        instance_eval(&specification)
      end

      def state_names
        states.keys
      end

      private

        def state(name, fails_to: nil)
          fail_state = nil
          if fails_to.present?
            fail_state = Stealth::Flow::State.new(fails_to, self)
          end

          new_state = Stealth::Flow::State.new(name, self, fail_state)
          @initial_state = new_state if @states.empty?
          @states[name.to_sym] = new_state
          @scoped_state = new_state
        end

    end
  end
end
