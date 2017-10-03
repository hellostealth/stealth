# coding: utf-8
# frozen_string_literal: true

require 'stealth/services/base_reply_handler'
require 'stealth/services/base_message_handler'

require 'stealth/services/jobs/handle_message_job'

module Stealth
  module Services
    class BaseClient

      attr_reader :reply

      def initialize(reply:)
        @reply = reply
      end

      def transmit
        raise(ServiceImpaired, "Service implementation does not implement 'transmit'.")
      end

    end
  end
end


require 'stealth/services/facebook/client'
