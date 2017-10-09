# coding: utf-8
# frozen_string_literal: true

require 'stealth/services/facebook/client'

module Stealth
  module Services
    module Facebook

      class Setup

        class << self
          def trigger
            reply_handler = Stealth::Services::Facebook::ReplyHandler.new
            reply = reply_handler.messenger_profile
            client = Stealth::Services::Facebook::Client.new(reply: reply)
            client.transmit
          end
        end

      end

    end
  end
end
