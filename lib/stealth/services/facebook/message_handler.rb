# coding: utf-8
# frozen_string_literal: true

require 'stealth/services/facebook/events/message_event'

module Stealth
  module Services
    module Facebook

      class MessageHandler < Stealth::Services::BaseMessageHandler

        attr_reader :service_message, :params, :headers, :facebook_message

        def initialize(params:, headers:)
          @params = params
          @headers = headers
        end

        def coordinate
          if facebook_is_validating_webhook?
            respond_with_validation
          else
            # Queue the request processing so we can respond quickly to FB
            # and also keep track of this message
            Stealth::Services::HandleMessageJob.perform_async('facebook', params, {})

            # Relay our acceptance
            [200, 'OK']
          end
        end

        def process
          @service_message = ServiceMessage.new(service: 'facebook')
          @facebook_message = params['entry'].first['messaging'].first
          service_message.sender_id = get_sender_id
          service_message.timestamp = get_timestamp
          process_message_event

          service_message
        end

        private

          def facebook_is_validating_webhook?
            params['hub.verify_token'].present?
          end

          def respond_with_validation
            if params['hub.verify_token'] == Stealth.config.facebook.verify_token
              [200, params['hub.challenge']]
            else
              [401, "Verify token did not match environment variable."]
            end
          end

          def get_sender_id
            facebook_message['sender']['id']
          end

          def get_timestamp
            Time.at(facebook_message['timestamp']).to_datetime
          end

          def process_message_event
            # We only support message events rn
            if facebook_message['message'].present?
              message_event = Stealth::Services::Facebook::MessageEvent.new(
                service_message: service_message,
                params: facebook_message
              )

              message_event.process
            end
          end
      end

    end
  end
end
