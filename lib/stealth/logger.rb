# coding: utf-8
# frozen_string_literal: true

module Stealth
  class Logger

    def self.log(topic:, message:)
      puts "[#{topic.upcase}] #{message}"
    end

    class << self
      alias_method :l, :log
    end

  end
end
