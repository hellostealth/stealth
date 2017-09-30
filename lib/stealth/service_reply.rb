# coding: utf-8
# frozen_string_literal: true

module Stealth
  class ServiceReply

    attr_accessor :recipient_id, :replies

    def initialize(recipient_id:, yaml_reply:, context:)
      @recipient_id = recipient_id

      begin
        erb_reply = ERB.new(yaml_reply).result(context)
      rescue NameError => e
        raise(Stealth::Errors::UndefinedVariable, e.message)
      end

      @replies = YAML.load(erb_reply)
    end

  end
end
