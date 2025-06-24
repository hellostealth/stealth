module Stealth
  module EventTriggers
    def trigger_event(event_name, action_name, service_event)
      EventManager.trigger_event(event_name, action_name, service_event)
    end

    def event(event_name, &block)
      EventManager.event(event_name, &block)
    end
  end
end
