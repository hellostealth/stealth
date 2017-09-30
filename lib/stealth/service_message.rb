# coding: utf-8
# frozen_string_literal: true

module Stealth
  class ServiceMessage

    attr_accessor :sender_id, :timestamp, :service, :message, :location,
                  :attachments

    def initialize(service:)
      @service = service
      @attachments = []
      @location = {}
    end

  end
end
