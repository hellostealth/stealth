# coding: utf-8
# frozen_string_literal: true

module Stealth
  class Controller

    attr_reader :current_message, :current_user_id, :current_flow,
                :current_state, :current_service, :flow_controller

    def initialize(service_message:, current_flow: nil, current_state: nil)
      @current_message = service_message
      @current_service = service_message.service
      @current_user_id = service_message.sender_id
      @current_flow = current_flow
      @current_state = current_state
    end

    def has_location?
      current_message.location.present?
    end

    def has_attachments?
      current_message.attachments.present?
    end

    def route
      raise(Stealth::Errors::ControllerRoutingNotImplemented, "Please implement `route` method in BotController.")
    end

    def send_replies
      service_reply = Stealth::ServiceReply.new(
        recipient_id: current_user_id,
        yaml_reply: action_replies,
        context: binding
      )

      for reply in service_reply.replies do
        handler = reply_handler.new(
          recipient_id: current_user_id,
          reply: reply
        )

        translated_reply = handler.send(reply.reply_type)
        client = service_client.new(reply: translated_reply)
        client.transmit

        # If this was a 'delay' type of reply, let's respect the delay
        if reply.reply_type == 'delay'
          begin
            sleep_duration = Float(reply["duration"])
            sleep(sleep_duration)
          rescue ArgumentError, TypeError
            raise(ArgumentError, 'Invalid duration specified. Duration must be a float.')
          end
        end
      end
    end

    def load_flow(session:)
      @flow_and_state = flow_and_state_from_session(session)
      flow_klass = [@flow_and_state.first, 'Flow'].join.classify.constantize
      @current_state = @flow_and_state.last
      @current_flow = flow_klass.new
      @current_flow.init_state(@current_state)
    end

    def flow_controller
      @flow_controller = begin
        flow_controller = [@flow_and_state.first.pluralize, 'Controller'].join.classify.constantize
        flow_controller.new(
          service_message: @current_message,
          current_flow: current_flow,
          current_state: current_state
        )
      end
    end

    def call_controller_action
      flow_controller.send(current_state)
    end

    def advance_to(flow:, state:)
      if defined?($redis)
        $redis.set(current_user_id, [flow, state].join('->'))
      else
        false
      end
    end

    private

      def reply_handler
        begin
          Kernel.const_get("Stealth::Services::#{current_service.capitalize}::ReplyHandler")
        rescue NameError
          raise(Stealth::Errors::ServiceNotRecognized, "The service '#{current_service}' was not recognized.")
        end
      end

      def service_client
        begin
          Kernel.const_get("Stealth::Services::#{current_service.capitalize}::Client")
        rescue NameError
          raise(Stealth::Errors::ServiceNotRecognized, "The service '#{current_service}' was not recognized.")
        end
      end

      def flow_and_state_from_session(session)
        session.split("->")
      end

      def replies_folder
        self.class.to_s.split('Controller').first.underscore
      end

      def action_replies
        File.read(File.join(Stealth.root, 'replies', replies_folder, "#{current_state}.yml"))
      end

  end
end
