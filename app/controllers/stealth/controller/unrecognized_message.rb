# coding: utf-8
# frozen_string_literal: true

module Stealth
  class Controller
    module UnrecognizedMessage
      extend ActiveSupport::Concern

      included do
        def run_unrecognized_message(err:)
          err_message = "The message \"#{current_message.message}\" was not recognized in the original context."

          Stealth::Logger.l(
            topic: 'unrecognized_message',
            message: err_message
          )

          flow_manager = Stealth::FlowManager.instance

          unless flow_manager.flow_exists?(:unrecognized_message) && flow_manager.state_exists?(:unrecognized_message, :handle_unrecognized_message)
            Stealth::Logger.l(
              topic: 'unrecognized_message',
              message: 'Running catch_all; unrecognized_message flow/state not defined.'
            )

            run_catch_all(err: err)
            return false
          end

          # Trigger the unrecognized message flow
          Stealth.trigger_flow(:unrecognized_message, :handle_unrecognized_message, current_message)
          # need to be changed
          run_catch_all(err: err)
          # begin
          #   if progressed?
          #     Stealth::Logger.l(
          #       topic: 'unrecognized_message',
          #       message: 'A match was detected. Skipping catch-all.'
          #     )
          #   else
          #     Stealth::Logger.l(
          #       topic: 'unrecognized_message',
          #       message: 'Did not send replies, update session, or step'
          #     )
          #   end
          # rescue StandardError => e
          #   # Run the catch_all directly since we're already in an unrecognized message state
          #   run_catch_all(err: e)
          # end
        end
      end
    end
  end
end
