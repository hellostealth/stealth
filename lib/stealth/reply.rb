# coding: utf-8
# frozen_string_literal: true

module Stealth
  class Reply

    attr_accessor :reply_type, :text, :buttons, :delay

    def initialize(reply_type:, text:, buttons: nil, delay: nil, details: nil)
      @reply_type = reply_type
      @text = text
      @buttons = buttons
      @delay = delay
      @details = details
    end

    def delay?
      delay.present?
    end

  end
end
