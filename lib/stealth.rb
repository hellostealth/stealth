require "stealth/version"
require "stealth/engine"
require "stealth/configuration/bandwidth"
require "stealth/event_manager"
require "stealth/event_triggers"
require "stealth/service_message"

module Stealth
  class << self
    include Stealth::EventTriggers

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

