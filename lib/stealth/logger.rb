# coding: utf-8
# frozen_string_literal: true

module Stealth
  class Logger

    def self.log(topic:, message:)
      unless ENV['STEALTH_ENV'] == 'test'
        puts "[#{topic.upcase}] #{message}"
      end
    end

    class << self
      alias_method :l, :log
    end

  end
end
