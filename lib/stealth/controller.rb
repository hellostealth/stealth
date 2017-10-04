# coding: utf-8
# frozen_string_literal: true

module Stealth
  class Controller

    attr_accessor :current_message

    def initialize(service_message:)
      @current_message = {
        sender_id: service_message.sender_id,
        timestamp: service_message.timestamp,
        text: service_message.message,
        location: service_message.location,
        attachments: service_message.attachments
      }

      @service = service_message.service
    end

    def current_service
      @service
    end

    def current_user_id
      current_message.sender_id
    end

    def has_location?
      current_message.location.present?
    end

    def has_attachments?
      current_message.location.present?
    end

    def route
      raise(ControllerRoutingNotImplemented, "Please implement `route` method in BotController.")
    end

    def send_replies(service_reply:)
      for reply in service_reply.replies do
        handler = reply_handler.new(
          recipient_id: current_sender_id,
          reply: reply
        )

        translated_reply = handler.send(reply.reply_type)
        client = service_client.new(reply: translated_reply)
        client.transmit

        # If this was a 'delay' type of reply, let's respect the delay
        if reply.reply_type == 'delay'
          begin
            sleep_duration = Float(reply["duration"])
            sleep(sleep_duration)
          rescue ArgumentError, TypeError
            raise(ArgumentError, 'Invalid duration specified. Duration must be a float.')
          end
        end
      end
    end

    private

      def reply_handler
        begin
          Kernel.const_get("Stealth::Services::#{current_service.capitalize}::ReplyHandler")
        rescue NameError
          raise(ServiceNotRecognized, "The service '#{current_service}' was not recognized.")
        end
      end

      def service_client
        begin
          Kernel.const_get("Stealth::Services::#{current_service.capitalize}::Client")
        rescue NameError
          raise(ServiceNotRecognized, "The service '#{current_service}' was not recognized.")
        end
      end

  end
end
