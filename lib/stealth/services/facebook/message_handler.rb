# coding: utf-8
# frozen_string_literal: true

module Stealth
  module Services
    module Facebook

      class MessageHandler < Stealth::Services::BaseMessageHandler

        attr_reader :service_response

        def initialize(params:, headers:)
          super
        end

        def coordinate
          if facebook_is_validating_webhook?
            respond_with_validation
          else
            # Queue the request processing so we can respond quickly to FB
            # and also keep track of this message
            Stealth::Services::Facebook::HandleRequestJob.perform_async(
              'facebook',
              params,
              headers
            )

            # Relay our acceptance
            [200, 'OK']
          end
        end

        def process
          @service_response = ServiceResponse.new(service: 'facebook')
          service_response.sender_id = get_sender_id
          service_response.timestamp = get_timestamp
          process_message_event

          service_response
        end

        private

          def facebook_is_validating_webhook?
            params['hub.verify_token'].present?
          end

          def respond_with_validation
            if params['hub.verify_token'] == ENV['FACEBOOK_VERIFY_TOKEN']
              [200, ENV['FACEBOOK_CHALLENGE']]
            else
              [401, "Verify token did not match environment variable."]
            end
          end

          def get_sender_id
            params['sender']['id']
          end

          def get_timestamp
            Time.at(params['sender']['timestamp']).to_datetime
          end

          def process_message_event
            # We only support message events rn
            if params['message'].present?
              message_event = Stealth::Services::Facebook::MessageEvent.new(
                service_response: service_response,
                params: params
              )

              message_event.process
            end
          end
      end

    end
  end
end
