# coding: utf-8
# frozen_string_literal: true

module Stealth
  class Logger

    COLORS = ::Hash[
      black:        30,
      red:          31,
      green:        32,
      yellow:       33,
      blue:         34,
      magenta:      35,
      cyan:         36,
      gray:         37,
      light_cyan:   96
    ].freeze

    def self.color_code(code)
      COLORS.fetch(code) { raise(ArgumentError, "Color #{code} not supported.") }
    end

    def self.colorize(input, color:)
      "\e[#{color_code(color)}m#{input}\e[0m"
    end

    def self.log(topic:, message:)
      unless ENV['STEALTH_ENV'] == 'test'
        puts "#{print_topic(topic)} #{message}"
      end
    end

    def self.print_topic(topic)
      topic_string = "[#{topic}]"

      case topic.to_sym
      when :session
        colorize(topic_string, color: :green)
      when :previous_session
        colorize(topic_string, color: :yellow)
      when :facebook, :twilio
        colorize(topic_string, color: :blue)
      when :smooch
        colorize(topic_string, color: :magenta)
      when :alexa
        colorize(topic_string, color: :light_cyan)
      when :catch_all
        colorize(topic_string, color: :red)
      else
        colorize(topic_string, color: :gray)
      end
    end

    class << self
      alias_method :l, :log
    end

  end
end
