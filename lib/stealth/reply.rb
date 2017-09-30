# coding: utf-8
# frozen_string_literal: true

module Stealth
  class Reply

    attr_accessor :reply_type, :text, :buttons, :delay

    def initialize(reply_type:, text:, buttons: {}, delay: {})
      @reply_type = reply_type
      @text = text
      @buttons = buttons
      @delay = delay
    end

    def delay?
      delay.present?
    end

  end
end
