# coding: utf-8
# frozen_string_literal: true

module Stealth
  module Services
    module Facebook

      class MessageEvent

        attr_reader :service_message, :params

        def initialize(service_message:, params:)
          @service_message = service_message
          @params = params
        end

        def process
          fetch_message
          fetch_location
          fetch_attachments
        end

        private

          def fetch_message
            if params['message']['quick_reply'].present?
              service_message.message = params['message']['quick_reply']['payload']
            elsif params['message']['text'].present?
              service_message.message = params['message']['text']
            end
          end

          def fetch_location
            if params['location'].present?
              lat = params['location']['coordinates']['lat']
              lng = params['location']['coordinates']['long']
              service_message.location = {
                lat: lat,
                lng: lng
              }
            end
          end

          def fetch_attachments
            if params['attachments'].present? && params['attachments'].is_a?(Array)
              params['attachments'].each do |attachment|
                service_message.attachments << {
                  type: attachment['type'],
                  url: attachment['payload']['url']
                }
              end
            end
          end

      end

    end
  end
end
