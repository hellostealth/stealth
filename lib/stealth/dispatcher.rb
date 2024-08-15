# coding: utf-8
# frozen_string_literal: true

module Stealth

  # Responsible for coordinating incoming events
  #  1. Receives incoming request params
  #  2. Initializes respective service request handler
  #  3. Processes params through service request handler (might be async)
  #  4. Inits base StealthController with state params returned from the service
  #     request handler
  #  5. Returns an HTTP response to be returned to the requestor
  class Dispatcher

    attr_reader :service, :params, :headers, :service_handler

    def initialize(service:, params:, headers:)
      @service = service
      @params = params
      @headers = headers
      @service_handler = service_handler_klass.new(
        params: params,
        headers: headers
      )
    end

    def coordinate
      service_handler.coordinate
    end

    def process
      service_event = service_handler.process

      if Stealth.config.transcript_logging
        log_incoming_message(service_event)
      end

      # This is where we will need to route to the new eventing system
      # bot_controller = BotController.new(service_message: service_message)
      # bot_controller.route
    end

    private

      def service_handler_klass
        begin
          Kernel.const_get("Stealth::Services::#{service.classify}::EventHandler")
        rescue NameError
          raise(Stealth::Errors::ServiceNotRecognized, "The service '#{service}' was not recognized")
        end
      end

      def log_incoming_message(service_event)
        event = if service_event.location.present?
                    "Received: <user shared location>"
                  elsif service_event.attachments.present?
                    "Received: <user sent attachment>"
                  elsif service_event.payload.present?
                    "Received Payload: #{service_event.payload}"
                  else
                    "Received Message: #{service_event.message}"
                  end

        Stealth::Logger.l(
          topic: 'user',
          message: "User #{service_event.sender_id} -> #{event}"
        )
      end
  end
end