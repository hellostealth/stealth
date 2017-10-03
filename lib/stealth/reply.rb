# coding: utf-8
# frozen_string_literal: true

module Stealth
  class Reply

    attr_accessor :reply_type, :reply

    def initialize(reply:)
      @reply_type = reply_type
      @reply = reply
    end

  end
end
