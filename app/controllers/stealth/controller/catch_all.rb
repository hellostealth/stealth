# coding: utf-8
# frozen_string_literal: true

# module Stealth
#   class Controller
#     module CatchAll

#       extend ActiveSupport::Concern

#       included do

#         def run_catch_all(err:)
#           error_level = fetch_error_level

#           if err.class == Stealth::Errors::UnrecognizedMessage
#             Stealth::Logger.l(
#               topic: 'catch_all',
#               message: "[Level #{error_level}] for user #{current_session_id} #{err.message}"
#             )
#           else
#             Stealth::Logger.l(
#               topic: 'catch_all',
#               message: "[Level #{error_level}] for user #{current_session_id} #{[err.class, err.message, err.backtrace.join("\n")].join("\n")}"
#             )
#           end

#           # Store the reason so it can be accessed by the CatchAllsController
#           current_message.catch_all_reason = {
#             err: err.class,
#             err_msg: err.message
#           }

#           # Don't run catch_all from the catch_all controller
#           if current_session.flow_string == 'catch_all'
#             Stealth::Logger.l(topic: 'catch_all', message: "CatchAll triggered for user #{current_session_id} from within CatchAll; ignoring.")
#             return false
#           end

#           if Stealth::FlowManager.instance.flow_exists?(:catch_all)
#             catch_all_state = calculate_catch_all_state(error_level)

#             if Stealth::FlowManager.instance.state_exists?(:catch_all, catch_all_state)
#               step_to flow: :catch_all, state: catch_all_state
#             else
#               Stealth::Logger.l(
#                 topic: 'catch_all',
#                 message: "Stopping; we've exceeded the number of defined catch_all states for user #{current_session_id}."
#               )
#               return false
#             end
#           end

#           # if defined?(CatchAllsController) && FlowMap.flow_spec[:catch_all].present?
#           #   catch_all_state = calculate_catch_all_state(error_level)

#           #   if FlowMap.flow_spec[:catch_all].states.keys.include?(catch_all_state.to_sym)
#           #     step_to flow: :catch_all, state: catch_all_state
#           #   else
#           #     # We are out of bounds, do nothing to prevent an infinite loop
#           #     Stealth::Logger.l(topic: 'catch_all', message: "Stopping; we\'ve exceeded the number of defined catch_all states for user #{current_session_id}.")
#           #     return false
#           #   end
#           # end
#         end

#         private

#           def fetch_error_level
#             if fail_attempts = $redis.get(error_slug)
#               begin
#                 fail_attempts = Integer(fail_attempts)
#               rescue ArgumentError
#                 fail_attempts = 1
#               end

#               fail_attempts += 1
#             else
#               fail_attempts = 1
#             end

#             # Set the error with an expiration to avoid filling Redis
#             $redis.setex(error_slug, 15.minutes.to_i, fail_attempts)

#             fail_attempts
#           end

#           def error_slug
#             ['error', current_session_id, current_session.flow_string, current_session.state_string].join('-')
#           end

#           def calculate_catch_all_state(error_level)
#             "level#{error_level}"
#           end

#       end

#     end
#   end
# end

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
