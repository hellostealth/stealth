# coding: utf-8
# frozen_string_literal: true

module Stealth
  class Controller
    module CatchAll

      extend ActiveSupport::Concern

      included do

        def run_catch_all(reason: nil)
          error_level = fetch_error_level
          Stealth::Logger.l(topic: "catch_all", message: "CatchAll #{calculate_catch_all_state(error_level)} triggered for #{error_slug}: #{reason}")

          if defined?(CatchAllsController) && defined?(CatchAllFlow)
            catch_all_state = calculate_catch_all_state(error_level)

            if CatchAllFlow.flow_spec.states.keys.include?(catch_all_state.to_sym)
              step_to flow: 'catch_all', state: catch_all_state
            else
              # Jump to the last catch_all state if we are out of bounds
              step_to flow: 'catch_all', state: CatchAllFlow.flow_spec.states.keys.last.to_s
            end
          end
        end

        private

          def fetch_error_level
            if fail_attempts = $redis.get(error_slug)
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
            $redis.setex(error_slug, 15.minutes.to_i, fail_attempts)

            fail_attempts
          end

          def error_slug
            ['error', current_user_id, current_session.flow_string, current_session.state_string].join('-')
          end

          def calculate_catch_all_state(error_level)
            "level#{error_level}"
          end

      end

    end
  end
end
