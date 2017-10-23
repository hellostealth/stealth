# coding: utf-8
# frozen_string_literal: true

module Stealth
  class Controller

    include ActiveSupport::Callbacks

    define_callbacks :action

    attr_reader :current_message, :current_user_id, :current_flow,
                :current_service, :flow_controller

    def initialize(service_message:, current_flow: nil)
      @current_message = service_message
      @current_service = service_message.service
      @current_user_id = service_message.sender_id
      @current_flow = current_flow
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

    def flow_controller
      @flow_controller = begin
        flow_controller = [current_session.flow_string.pluralize, 'controller'].join('_').classify.constantize
        flow_controller.new(
          service_message: @current_message,
          current_flow: current_flow
        )
      end
    end

    def current_session
      @current_session ||= Stealth::Session.new(user_id: current_user_id)
    end

    def action(action: nil)
      run_callbacks :action do
        action ||= current_session.state_string
        flow_controller.send(action)
      end
    end

    def step_to(session: nil, flow: nil, state: nil)
      if session.nil? && flow.nil? && state.nil?
        raise(ArgumentError, "A session, flow, or state must be specified.")
      end

      if session.present?
        step_to_session(session)
        return
      end

      if flow.present?
        step_to_flow(flow: flow, state: state)
        return
      end

      if state.present?
        step_to_state(state)
        return
      end
    end

    def step_to_next
      step_to_next_state
    end

    def self.before_action(*args, &block)
      set_callback(:action, :before, *args, &block)
    end

    def self.around_action(*args, &block)
      set_callback(:action, :around, *args, &block)
    end

    def self.after_action(*args, &block)
      set_callback(:action, :after, *args, &block)
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

      def replies_folder
        current_session.flow_string.underscore.pluralize
      end

      def action_replies
        File.read(File.join(Stealth.root, 'bot', 'replies', replies_folder, "#{current_session.state_string}.yml"))
      end

      def step(flow:, state:)
        session = Stealth::Session.new(user_id: current_user_id)
        session.set(flow: flow, state: state)
        @current_session = session
        @current_flow = session.flow

        action(action: state)
      end

      def step_to_session(session)
        step(flow: session.flow_string, state: session.state_string)
      end

      def step_to_flow(flow:, state:)
        if state.blank?
          flow_klass = [flow, 'flow'].join('_').classify.constantize
          state = flow_klass.flow_spec.states.keys.first
        end

        step(flow: flow, state: state)
      end

      def step_to_state(state)
        step(flow: current_session.flow_string, state: state)
      end

      def step_to_next_state
        current_state_index = current_flow.states.index(current_flow.state_string.to_sym)
        next_state = current_flow.states[current_state_index + 1]
        if next_state.nil?
          raise(
            Stealth::Errors::InvalidStateTransitions,
            "The next state after #{current_flow.state_string} has not yet been defined."
          )
        end

        step(flow: current_flow.flow_string, state: next_state)
      end

  end
end
