# coding: utf-8
# frozen_string_literal: true

module Stealth
  class Controller
    module CatchAll

      extend ActiveSupport::Concern

      included do

        def run_catch_all(err:)
          error_level = fetch_error_level

          if err.class == Stealth::Errors::UnrecognizedMessage
            Stealth::Logger.l(
              topic: 'catch_all',
              message: "[Level #{error_level}] for user #{current_session_id} #{err.message}"
            )
          else
            Stealth::Logger.l(
              topic: 'catch_all',
              message: "[Level #{error_level}] for user #{current_session_id} #{[err.class, err.message, err.backtrace.join("\n")].join("\n")}"
            )
          end

          # Store the reason so it can be accessed by the CatchAllsController
          current_message.catch_all_reason = {
            err: err.class,
            err_msg: err.message
          }

          # Don't run catch_all from the catch_all controller
          if current_session.flow_string == 'catch_all'
            Stealth::Logger.l(topic: 'catch_all', message: "CatchAll triggered for user #{current_session_id} from within CatchAll; ignoring.")
            return false
          end

          if defined?(CatchAllsController) && FlowMap.flow_spec[:catch_all].present?
            catch_all_state = calculate_catch_all_state(error_level)

            if FlowMap.flow_spec[:catch_all].states.keys.include?(catch_all_state.to_sym)
              step_to flow: :catch_all, state: catch_all_state
            else
              # We are out of bounds, do nothing to prevent an infinite loop
              Stealth::Logger.l(topic: 'catch_all', message: "Stopping; we\'ve exceeded the number of defined catch_all states for user #{current_session_id}.")
              return false
            end
          end
        end

        private

          def fetch_error_level
            if fail_attempts = Stealth::RedisSupport.with { |r| r.get(error_slug) }
              begin
                fail_attempts = Integer(fail_attempts)
              rescue ArgumentError
                fail_attempts = 1
              end

              fail_attempts += 1
            else
              fail_attempts = 1
            end

            # Set the error with an expiration to avoid filling Redis
            Stealth::RedisSupport.with { |r| r.setex(error_slug, 15.minutes.to_i, fail_attempts) }

            fail_attempts
          end

          def error_slug
            ['error', current_session_id, current_session.flow_string, current_session.state_string].join('-')
          end

          def calculate_catch_all_state(error_level)
            "level#{error_level}"
          end

      end

    end
  end
end
