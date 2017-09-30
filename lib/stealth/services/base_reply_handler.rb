# coding: utf-8
# frozen_string_literal: true

module Stealth
  module Services
    class BaseReplyHandler

      attr_reader :client

      def initialize(client:, options: {})
        @client = client
        @options = options
      end

      def text(text:, suggestions: [], buttons: [])
        reply_format_not_supported(format: 'text')
      end

      def image(image_url:, suggestions: [], buttons: [])
        reply_format_not_supported(format: 'image')
      end

      def audio(audio_url:, suggestions: [], buttons: [])
        reply_format_not_supported(format: 'audio')
      end

      def video(video_url:, suggestions: [], buttons: [])
        reply_format_not_supported(format: 'video')
      end

      def file(file_url:, suggestions: [], buttons: [])
        reply_format_not_supported(format: 'file')
      end

      def cards(details:)
        reply_format_not_supported(format: 'cards')
      end

      def list(details:)
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

      private

        def check_if_arguments_are_valid!(suggestions:, buttons:)
          if !suggestions.empty? && !buttons.empty?
            raise(ArgumentError, "A reply cannot have buttons and suggestions!")
          end
        end

    end
  end
end
