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
      light_cyan:   96,
      white:        97
    ].freeze

    def self.color_code(code)
      COLORS.fetch(code) { raise(ArgumentError, "Color #{code} not supported.") }
    end

    def self.colorize(input, color:)
      "\e[#{color_code(color)}m#{input}\e[0m"
    end

    def self.log(topic:, message:)
      unless ENV['STEALTH_ENV'] == 'test'
        puts "TID-#{Stealth.tid} #{print_topic(topic)} #{message}"
      end
    end

    def self.print_topic(topic)
      topic_string = "[#{topic}]"

      color = case topic.to_sym
              when :primary_session
                :green
              when :previous_session, :back_to_session
                :yellow
              when :interrupt
                :magenta
              when :facebook, :twilio, :bandwidth
                :blue
              when :smooch
                :magenta
              when :alexa, :voice, :twilio_voice, :unrecognized_message
                :light_cyan
              when :nlp
                :cyan
              when :catch_all, :err
                :red
              when :user
                :white
              else
                :gray
              end

      colorize(topic_string, color: color)
    end

    class << self
      alias_method :l, :log
    end

  end
end