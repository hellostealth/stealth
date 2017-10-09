# coding: utf-8
# frozen_string_literal: true

require 'stealth/services/facebook/message_handler'
require 'stealth/services/facebook/reply_handler'

module Stealth
  module Services
    module Facebook

      class Client < Stealth::Services::BaseClient
        FB_ENDPOINT = "https://graph.facebook.com/v2.10/me/messages"

        attr_reader :api_endpoint, :reply

        def initialize(reply:)
          @reply = reply
          access_token = "access_token=#{Stealth.config.facebook.page_access_token}"
          @api_endpoint = [FB_ENDPOINT, access_token].join('?')
        end

        def transmit
          headers = { "Content-Type" => "application/json" }
          Faraday.post(api_endpoint, reply.to_json, headers)
        end

      end

    end
  end
end
