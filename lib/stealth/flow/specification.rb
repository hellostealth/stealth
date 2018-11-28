# coding: utf-8
# frozen_string_literal: true

module Stealth
  module Flow
    class Specification
      attr_reader :flow_name
      attr_accessor :states, :initial_state

      def initialize(flow_name, &specification)
        @states = Hash.new
        @flow_name = flow_name
        instance_eval(&specification)
      end

      def state_names
        states.keys
      end

      private

        def state(name, fails_to: nil, redirects_to: nil)
          fail_state = get_fail_or_redirect_state(fails_to)
          redirect_state = get_fail_or_redirect_state(redirects_to)

          new_state = Stealth::Flow::State.new(
            name: name,
            spec: self,
            fails_to: fail_state,
            redirects_to: redirect_state
          )

          @initial_state = new_state if @states.empty?
          @states[name.to_sym] = new_state
        end

        def get_fail_or_redirect_state(specified_state)
          if specified_state.present?
            session = Stealth::Session.new

            if Stealth::Session.is_a_session_string?(specified_state)
              session.session = specified_state
            else
              session.session = Stealth::Session.canonical_session_slug(
                flow: flow_name,
                state: specified_state
              )
            end

            return session
          end
        end

    end
  end
end
