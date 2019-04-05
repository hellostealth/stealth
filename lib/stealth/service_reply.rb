# coding: utf-8
# frozen_string_literal: true

module Stealth
  class ServiceReply

    attr_accessor :recipient_id, :replies, :yaml_reply, :context

    def initialize(recipient_id:, yaml_reply:, context:, preprocessor: :none)
      @recipient_id = recipient_id
      @yaml_reply = yaml_reply
      @context = context

      processed_reply = case preprocessor
      when :erb
        preprocess_erb
      when :none
        @yaml_reply
      end

      if yaml_reply.is_a?(Array)
        @replies = load_replies(@yaml_reply)
      else
        @replies = load_replies(YAML.load(processed_reply))
      end
    end

    private

      def load_replies(unstructured_replies)
        unstructured_replies.collect do |reply|
          Stealth::Reply.new(unstructured_reply: reply)
        end
      end

      def preprocess_erb
        begin
          ERB.new(yaml_reply).result(context)
        rescue NameError => e
          raise(Stealth::Errors::UndefinedVariable, e.message)
        end
      end

  end
end
