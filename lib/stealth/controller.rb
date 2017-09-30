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

    def has_location?
      current_message.location.present?
    end

    def has_attachments?
      current_message.location.present?
    end

    def route
      raise(ControllerRoutingNotImplemented, "Please implement `route` method in BotController.")
    end

  end
end
