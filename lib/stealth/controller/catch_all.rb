# coding: utf-8
# frozen_string_literal: true

module Stealth
  class Controller
    module CatchAll

      extend ActiveSupport::Concern

      included do

        def run_catch_all
          error_level = fetch_error_level

          if defined?(CatchAllsController)
            step_to flow: 'catch_all', state: catch_all_state(error_level)
          end
        end

        private

          def fetch_error_level
            if fail_attempts = $redis.get(error_slug)
              fail_attempts += 1
            else
              fail_attempts = 1
            end

            # Set the error with an expiration to avoid filling Redis
            $redis.setex(error_slug, 15.minutes.to_i, fail_attempts)

            fail_attempts
          end

          def error_slug
            ['error', current_user_id, current_flow.flow_string, current_flow.state_string].join('-')
          end

          def catch_all_state(error_level)
            "level#{error_level}"
          end

      end

    end
  end
end
