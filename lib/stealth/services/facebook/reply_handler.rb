# coding: utf-8
# frozen_string_literal: true

module Stealth
  module Services
    module Facebook

      class ReplyHandler < Stealth::Services::BaseReplyHandler
        def text(text:)
          template = {
            "recipient" => {
              "id" => recipient_id
            },
            "message" => {
              "text" => text
            }
          }
        end

        def image(image_url:)
          reply_format_not_supported(format: 'image')
        end

        def text_suggestions(text:, suggestions:)
          reply_format_not_supported(format: 'text_suggestions')
        end

        def text_buttons(text:, buttons:)
          reply_format_not_supported(format: 'text_buttons')
        end

        def image_suggestions(image_url:)
          reply_format_not_supported(format: 'image_suggestions')
        end

        def image_buttons
          reply_format_not_supported(format: 'image_buttons')
        end

        def card
          reply_format_not_supported(format: 'card')
        end

        def cards
          reply_format_not_supported(format: 'cards')
        end

        def receipt
          reply_format_not_supported(format: 'receipt')
        end
      end

    end
  end
end
