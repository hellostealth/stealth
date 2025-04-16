module Stealth
  class FlowManager
    def initialize
      @flows = Hash.new { |hash, key| hash[key] = {} }
    end

    def register_flow(flow_name, &block)
      @current_flow = flow_name.to_sym

      @flows[@current_flow] = {
        states: {},
        callbacks: Hash.new { |h, k| h[k] = [] }
      }

      instance_eval(&block)
      @current_flow = nil
    end

    def state(state_name, **options, &block)
      @flows[@current_flow][:states][state_name.to_sym] = {
        block: block,
        options: options
      }
    end

    def current_state(session)
      return nil if session.flow.blank? || session.state.blank?

      flow_states = @flows[session.flow_string.to_sym]
      return nil unless flow_states

      flow_states[:states][session.state.to_sym]
    end

    def trigger_flow(flow_name, state_name, service_event)
      flow_name = flow_name.to_sym
      state_name = state_name.to_sym

      flow = @flows[flow_name]
      return unless flow

      state_info = flow[:states][state_name]
      return unless state_info

      block = state_info[:block]
      options = state_info[:options]

      context_class = defined?(Stealth::DslEventContext) ? Stealth::DslEventContext : Stealth::Controller
      context = context_class.new(service_event: service_event)

      callbacks = flow[:callbacks] || {}

      callbacks[:before_state]&.each do |callback|
        context.public_send(callback) if context.respond_to?(callback)
      end

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

      around_callbacks = callbacks[:around_state] || []
      if around_callbacks.any?
        chain = around_callbacks.reverse.inject(-> { block_context.instance_exec(service_event, &block) }) do |next_proc, callback|
          -> { context.public_send(callback) { next_proc.call } }
        end
        chain.call
      else
        block_context.instance_exec(service_event, &block)
      end

      callbacks[:after_state]&.each do |callback|
        context.public_send(callback) if context.respond_to?(callback)
      end
    end

    def flow_exists?(flow_name)
      @flows.key?(flow_name.to_sym)
    end

    def state_exists?(flow_name, state_name)
      @flows.dig(flow_name.to_sym, :states, state_name.to_sym).present?
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

    # Callbacks
    def before_state(method_name)
      @flows[@current_flow][:callbacks][:before_state] << method_name
    end

    def after_state(method_name)
      @flows[@current_flow][:callbacks][:after_state] << method_name
    end

    def around_state(method_name)
      @flows[@current_flow][:callbacks][:around_state] << method_name
    end

  end
end
