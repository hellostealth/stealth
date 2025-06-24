# coding: utf-8
# frozen_string_literal: true

module Stealth
  class Controller

    module DynamicDelay
      extend ActiveSupport::Concern

      SHORT_DELAY = 3.0
      STANDARD_DELAY = 4.3
      LONG_DELAY = 7.0

      included do
        def dynamic_delay(previous_reply:)
          calculate_delay(previous_reply: previous_reply)
        end

        private

        def calculate_delay(previous_reply:)
          return SHORT_DELAY if previous_reply.blank?

          case previous_reply['reply_type']
          when 'text'
            calculate_delay_from_text(previous_reply['text'])
          when 'image'
            STANDARD_DELAY
          when 'audio'
            STANDARD_DELAY
          when 'video'
            STANDARD_DELAY
          when 'file'
            STANDARD_DELAY
          when 'cards'
            STANDARD_DELAY
          when 'list'
            STANDARD_DELAY
          when nil
            SHORT_DELAY
          else
            SHORT_DELAY
          end
        end
      end

      def calculate_delay_from_text(text)
        case text.size
        when 0..55
          SHORT_DELAY
        when 56..140
          STANDARD_DELAY
        when 141..256
          STANDARD_DELAY * 1.5
        else
          LONG_DELAY
        end
      end
    end

  end
end
