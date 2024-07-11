require "stealth/version"
require "stealth/engine"
require "stealth/configuration/bandwidth"

module Stealth
  class << self
    attr_accessor :configurations

    def setup
      self.configurations ||= {}
      yield(self)
    end

    def configure_bandwidth
      self.configurations[:bandwidth] ||= Bandwidth.new
      yield(configurations[:bandwidth])
    end

  end
end

