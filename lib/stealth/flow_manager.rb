module Stealth
  class FlowManager
    def initialize
      @flows = Hash.new { |hash, key| hash[key] = {} }
    end

    def register_flow(flow_name, &block)
      @current_flow = flow_name.to_sym
      instance_eval(&block)
      @current_flow = nil
    end

    def state(state_name, **options, &block)
      @flows[@current_flow] ||= {}
      @flows[@current_flow][state_name.to_sym] = { block: block, options: options }
    end

    def current_state(session)
      return nil if session.flow.blank? || session.state.blank?

      flow_states = @flows[session.flow_string.to_sym]
      return nil unless flow_states

      flow_states[session.state]
    end

    def trigger_flow(flow_name, state_name, service_event)
      flow_name = flow_name.to_sym
      state_name = state_name.to_sym

      if @flows[flow_name] && @flows[flow_name][state_name]
        state_info = @flows[flow_name][state_name]
        block = state_info[:block]
        options = state_info[:options]

        # Always use DslEventContext if defined in the Rails app
        context_class = defined?(Stealth::DslEventContext) ? Stealth::DslEventContext : Stealth::Controller
        context = context_class.new(service_event: service_event)

        block_context = Class.new do
          def initialize(context, options)
            @context = context
            @options = options
          end

          def method_missing(method_name, *args, **kwargs, &block)
            if @context.respond_to?(method_name)
              @context.public_send(method_name, *args, **kwargs, &block)
            else
              super
            end
          end

          def respond_to_missing?(method_name, include_private = false)
            @context.respond_to?(method_name) || super
          end

          def state_options
            @options
          end
        end.new(context, options)

        block_context.instance_exec(service_event, &block)
      else
        Stealth::Logger.l(topic: 'user', message: "No flow found for #{flow_name} with state #{state_name}")
      end
    end

    def flow_exists?(flow_name)
      @flows.key?(flow_name.to_sym)
    end

    def state_exists?(flow_name, state_name)
      @flows.dig(flow_name.to_sym, state_name.to_sym).present?
    end

    def self.instance
      @instance ||= new
    end

    def self.flow(flow_name, &block)
      instance.register_flow(flow_name, &block)
    end

    def self.trigger_flow(flow_name, state_name, service_event)
      instance.trigger_flow(flow_name, state_name, service_event)
    end
  end
end
