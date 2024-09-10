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

        # Always use DslEventContext if defined in the Rails app
        # DslEventContext inherits from Stealth::EventContext
        context_class = defined?(Stealth::DslEventContext) ? Stealth::DslEventContext : Stealth::EventContext
        context = context_class.new(controller)

        block_context = Class.new do
          def initialize(context)
            @context = context
          end

          def method_missing(method_name, *args, &block)
            if @context.respond_to?(method_name)
              @context.public_send(method_name, *args, &block)
            else
              super
            end
          end

          def respond_to_missing?(method_name, include_private = false)
            @context.respond_to?(method_name) || super
          end
        end.new(context)

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

