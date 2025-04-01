# coding: utf-8
# frozen_string_literal: true

module Stealth
  class Reply
    attr_reader :reply_type, :reply

    def initialize(unstructured_reply:)
      @reply = sanitize_reply(unstructured_reply)
      @reply_type = @reply[:reply_type]
    end

    def [](key)
      @reply[key]
    end

    def []=(key, value)
      @reply[key] = value
    end

    def delay?
      reply_type == 'delay'
    end

    private

    def sanitize_reply(reply)
      raise "Invalid reply format. Expected a Hash." unless reply.is_a?(Hash)

      sanitized_reply = reply.transform_values { |value| sanitize(value) }

      # Default reply_type to "text" only if it's still missing
      sanitized_reply[:reply_type] ||= "text" if sanitized_reply[:reply_type].nil?

      if sanitized_reply[:suggestions].is_a?(String)
        sanitized_reply[:suggestions] = JSON.parse(sanitized_reply[:suggestions])
      end

      sanitized_reply
    end

    def sanitize(value)
      return value unless value.is_a?(String)
      ActionView::Base.full_sanitizer.sanitize(value)
    end

  end
end
