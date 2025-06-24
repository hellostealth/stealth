module Stealth
  class ReplyManager
    def initialize
      @replies = {}
    end

    def register_reply(flow_name, state_name, &block)
      flow_state_key = "#{flow_name}/#{state_name}".to_sym
      @replies[flow_state_key] = block
    end

    def trigger_reply(flow_name, state_name, service_event)
      flow_state_key = "#{flow_name}/#{state_name}".to_sym

      if Stealth.env.development?
        load_reply_file(flow_name, state_name)  # force reload on every request in dev
      else
        load_reply_file(flow_name, state_name) unless @replies.key?(flow_state_key)
      end

      if @replies.key?(flow_state_key)
        block = @replies[flow_state_key]

        # Always use DslEventContext if defined in the Rails app
        context_class = defined?(Stealth::DslEventContext) ? Stealth::DslEventContext : Stealth::Controller
        context = context_class.new(service_event: service_event)

        block_context = Class.new do
          def initialize(context)
            @context = context
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
        end.new(context)

        block_context.instance_exec(service_event, &block)
      else
        Stealth::Logger.l(topic: 'reply', message: "No reply found for #{flow_name} with state #{state_name}")
      end
    end

    def load_reply_file(flow_name, state_name)
      reply_file_path = "stealth/replies/#{flow_name}/#{state_name}.rb"

      if File.exist?(reply_file_path)
        load reply_file_path
      else
        Stealth::Logger.l(topic: 'reply', message: "Reply file not found: #{reply_file_path}")
      end
    end

    def self.instance
      @instance ||= new
    end

    def self.reply(&block)
      # Search through the call stack to find the Rails app reply file path
      file_path = caller_locations.find { |location| location.path.include?("stealth/replies") }.path
      # Extract flow and state from the file path, assuming the path structure matches "stealth/replies/flow_name/state_name.rb"
      match_data = file_path.match(%r{stealth/replies/(?<flow_name>[^/]+)/(?<state_name>[^/]+)\.rb})

      if match_data
        flow_name = match_data[:flow_name]
        state_name = match_data[:state_name]

        # Register the reply with inferred flow and state
        instance.register_reply(flow_name, state_name, &block)
      else
        raise "Unable to determine flow and state from file path: #{file_path}"
      end
    end

    def self.trigger_reply(flow_name, state_name, service_event)
      instance.trigger_reply(flow_name, state_name, service_event)
    end

  end
end
