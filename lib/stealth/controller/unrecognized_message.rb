# coding: utf-8
# frozen_string_literal: true

module Stealth
  class Controller
    module UnrecognizedMessage

      extend ActiveSupport::Concern

      included do

        def run_unrecognized_message(err:)
          err_message = "The message \"#{current_message.message}\" was not recognized."

          Stealth::Logger.l(
            topic: 'unrecognized_message',
            message: err_message
          )

          unless defined?(UnrecognizedMessagesController)
            Stealth::Logger.l(
              topic: 'unrecognized_message',
              message: 'Running catch_all; UnrecognizedMessagesController not defined.'
            )

            run_catch_all(err: err)
            return false
          end

          unrecognized_msg_controller = UnrecognizedMessagesController.new(
            service_message: current_message
          )

          begin
            # Run handle_unrecognized_message action
            unrecognized_msg_controller.handle_unrecognized_message

            unless unrecognized_msg_controller.progressed?
              # Log, but we don't want to run the catch_all for a poorly
              # coded UnrecognizedMessagesController
              Stealth::Logger.l(
                topic: 'unrecognized_message',
                message: 'Did not send replies, update session, or step'
              )
            end
          rescue StandardError => e
            # Run the catch_all directly since we're already in an unrecognized
            # message state
            run_catch_all(err: e)
          end
        end

      end

    end
  end
end
