# coding: utf-8
# frozen_string_literal: true

module Stealth
  class Controller
    module Replies

      extend ActiveSupport::Concern

      included do

        def send_replies
          service_reply = Stealth::ServiceReply.new(
            recipient_id: current_user_id,
            yaml_reply: action_replies,
            context: binding
          )

          for reply in service_reply.replies do
            handler = reply_handler.new(
              recipient_id: current_user_id,
              reply: reply
            )

            translated_reply = handler.send(reply.reply_type)
            client = service_client.new(reply: translated_reply)
            client.transmit

            # If this was a 'delay' type of reply, we insert the delay
            if reply.reply_type == 'delay'
              begin
                sleep_duration = Float(reply["duration"])
                sleep(sleep_duration)
              rescue ArgumentError, TypeError
                raise(ArgumentError, 'Invalid duration specified. Duration must be a float')
              end
            end
          end

          @progressed = :sent_replies
        end

      end

    end
  end
end
