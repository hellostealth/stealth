# coding: utf-8
# frozen_string_literal: true

module Stealth
  class Controller
    module CatchAll
      extend ActiveSupport::Concern

      included do
        def run_catch_all(err:)
          error_level = fetch_error_level

          log_catch_all_error(err, error_level)

          # Store the reason so it can be accessed by the CatchAll flow
          current_message.catch_all_reason = {
            err: err.class,
            err_msg: err.message
          }

          # Avoid infinite loops if already in catch_all flow
          if current_session.flow_string == 'catch_all'
            Stealth::Logger.l(
              topic: 'catch_all',
              message: "CatchAll triggered from within CatchAll; ignoring for user #{current_session_id}."
            )
            return false
          end

          flow_manager = Stealth::FlowManager.instance

          if flow_manager.flow_exists?(:catch_all)
            catch_all_state = calculate_catch_all_state(error_level)

            if flow_manager.state_exists?(:catch_all, catch_all_state)
              Stealth.trigger_flow(:catch_all, catch_all_state, current_message)
            else
              Stealth::Logger.l(
                topic: 'catch_all',
                message: "Stopping; exceeded the number of defined catch_all states for user #{current_session_id}."
              )
              return false
            end
          end
        end

        private

        def fetch_error_level
          fail_attempts = ($redis.get(error_slug) || 0).to_i + 1
          $redis.setex(error_slug, 15.minutes.to_i, fail_attempts) # Store error level for 15 min
          fail_attempts
        end

        def error_slug
          "error-#{current_session_id}-#{current_session.flow_string}-#{current_session.state_string}"
        end

        def calculate_catch_all_state(error_level)
          "level#{error_level}".to_sym
        end

        def log_catch_all_error(err, error_level)
          error_message = err.is_a?(Stealth::Errors::UnrecognizedMessage) ? err.message : [err.class, err.message, err.backtrace&.join("\n")].join("\n")

          Stealth::Logger.l(
            topic: 'catch_all',
            message: "[Level #{error_level}] for user #{current_session_id}: #{error_message}"
          )
        end
      end
    end
  end
end
