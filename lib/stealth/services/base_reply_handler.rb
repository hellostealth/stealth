# coding: utf-8
# frozen_string_literal: true

module Stealth
  module Services
    class BaseReplyHandler

      attr_reader :recipient_id, :reply

      def initialize(recipient_id:, reply:)
        @client = client
        @options = options
      end

      def text
        reply_format_not_supported(format: 'text')
      end

      def image
        reply_format_not_supported(format: 'image')
      end

      def audio
        reply_format_not_supported(format: 'audio')
      end

      def video
        reply_format_not_supported(format: 'video')
      end

      def file
        reply_format_not_supported(format: 'file')
      end

      def cards
        reply_format_not_supported(format: 'cards')
      end

      def list
        reply_format_not_supported(format: 'list')
      end

      def receipt
        reply_format_not_supported(format: 'receipt')
      end

      def mark_seen
        reply_format_not_supported(format: 'mark_seen')
      end

      def enable_typing_indicator
        reply_format_not_supported(format: 'enable_typing_indicator')
      end

      def disable_typing_indicator
        reply_format_not_supported(format: 'disable_typing_indicator')
      end

    end
  end
end
