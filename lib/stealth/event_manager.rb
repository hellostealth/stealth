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

    def trigger_event(event_name, action_name, service_event)
      if @events[event_name] && @events[event_name][action_name]

        controller = Stealth::Controller.new(service_event: service_event)

        block_context = Class.new do
          define_method(:current_message) { controller.current_message }
          define_method(:current_service) { controller.current_service }
          define_method(:current_session_id) { controller.current_session_id }
          define_method(:current_session) { controller.current_session }
          define_method(:has_location?) { controller.has_location? }
          define_method(:has_attachments?) { controller.has_attachments? }
        end.new

        block_context.instance_exec(service_event, &@events[event_name][action_name])
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

    def self.trigger_event(event_name, action_name, service_event)
      instance.trigger_event(event_name, action_name, service_event)
    end

  end
end

