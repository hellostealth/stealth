# coding: utf-8
# frozen_string_literal: true

require 'faraday'

require 'stealth/services/facebook/message_handler'
require 'stealth/services/facebook/reply_handler'
require 'stealth/services/facebook/setup'

module Stealth
  module Services
    module Facebook

      class Client < Stealth::Services::BaseClient
        FB_ENDPOINT = "https://graph.facebook.com/v2.10/me"

        attr_reader :api_endpoint, :reply

        def initialize(reply:, endpoint: 'messages')
          @reply = reply
          access_token = "access_token=#{Stealth.config.facebook.page_access_token}"
          @api_endpoint = [[FB_ENDPOINT, endpoint].join('/'), access_token].join('?')
        end

        def transmit
          headers = { "Content-Type" => "application/json" }
          response = Faraday.post(api_endpoint, reply.to_json, headers)
          Stealth::Logger.l(topic: "facebook", message: "Transmitting. Response: #{response.status}: #{response.body}")
        end

      end

    end
  end
end
