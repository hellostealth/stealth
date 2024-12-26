# coding: utf-8
# frozen_string_literal: true

module Stealth
  class Reply
    attr_reader :reply_type, :reply, :sanitized

    def initialize(unstructured_reply:, sanitized: true)
      @reply = sanitize_reply(unstructured_reply)
      @reply_type = determine_reply_type
      @sanitized = sanitized
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

    def determine_reply_type
      # WIP
      # makes lighter synthax for text reply type
      if @reply.key?(:text) || @reply[:reply_type] == 'text'
        'text'
      elsif @reply[:reply_type] == 'image'
        'image'
      elsif @reply[:reply_type] == 'dropdown'
        'dropdown'
      else
        raise "No valid reply type found."
      end
    end

    def sanitize_reply(reply)
      # If the reply is a String, default it to a text reply
      if reply.is_a?(String)
        { text: sanitize(reply) }
      elsif reply.is_a?(Hash)
        reply.transform_values { |value| sanitize(value) }
      else
        raise "Invalid reply type. Must be a String or Hash."
      end
    end

    def sanitize(value)
      if sanitized
        ActionView::Base.full_sanitizer.sanitize(value)
      else
        value
      end
    end
  end
end

# module Stealth
#   class Reply

#     attr_accessor :reply_type, :reply

#     def initialize(unstructured_reply:)
#       @reply_type = unstructured_reply["reply_type"]
#       @reply = unstructured_reply
#     end

#     def [](key)
#       @reply[key]
#     end

#     def []=(key, value)
#       @reply[key] = value
#     end

#     def delay?
#       reply_type == 'delay'
#     end

#     def self.dynamic_delay
#       self.new(
#         unstructured_reply: {
#           'reply_type' => 'delay',
#           'duration' => 'dynamic'
#         }
#       )
#     end

#   end
# end
