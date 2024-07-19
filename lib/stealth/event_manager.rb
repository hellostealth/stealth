module Stealth
  class EventManager
    def initialize
      @events = Hash.new { |hash, key| hash[key] = {} }
    end

    def register_event(event_name, &block)
      @current_event = event_name
      instance_eval(&block)
      @current_event = nil
    end

    def on(action_name, &block)
      @events[@current_event][action_name] = block
    end

    def trigger_event(event_name, action_name, request)
      if @events[event_name] && @events[event_name][action_name]
        @events[event_name][action_name].call(request)
      else
        Rails.logger.warn "No handler for #{event_name} #{action_name}"
      end
    end

    def self.instance
      @instance ||= new
    end

    def self.event(event_name, &block)
      instance.register_event(event_name, &block)
    end

    def self.trigger_event(event_name, action_name, request)
      instance.trigger_event(event_name, action_name, request)
    end

  end
end

