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
      raise(Stealth::Errors::ControllerRoutingNotImplemented, "Please implement `route` method in BotController")
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
            raise(ArgumentError, 'Invalid duration specified. Duration must be a float')
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

    def step_to_in(delay, session: nil, flow: nil, state: nil)
      flow, state = get_flow_and_state(session: session, flow: flow, state: state)

      unless delay.is_a?(ActiveSupport::Duration)
        raise ArgumentError, "Please specify your schedule_step_to `in` parameter using ActiveSupport::Duration, e.g. `1.day` or `5.hours`"
      end

      Stealth::ScheduledReplyJob.perform_in(delay, current_service, current_user_id, flow, state)
    end

    def step_to(session: nil, flow: nil, state: nil)
      flow, state = get_flow_and_state(session: session, flow: flow, state: state)
      step(flow: flow, state: state)
    end

    def update_session_to(session: nil, flow: nil, state: nil)
      flow, state = get_flow_and_state(session: session, flow: flow, state: state)
      update_session(flow: flow, state: state)
    end

    def step_to_next
      flow, state = get_next_state
      step(flow: flow, state: state)
    end

    def update_session_to_next
      flow, state = get_next_state
      update_session(flow: flow, state: state)
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
          raise(Stealth::Errors::ServiceNotRecognized, "The service '#{current_service}' was not recognized")
        end
      end

      def service_client
        begin
          Kernel.const_get("Stealth::Services::#{current_service.capitalize}::Client")
        rescue NameError
          raise(Stealth::Errors::ServiceNotRecognized, "The service '#{current_service}' was not recognized")
        end
      end

      def replies_folder
        current_session.flow_string.underscore.pluralize
      end

      def action_replies
        reply_file_path = File.join(Stealth.root, 'bot', 'replies', replies_folder, "#{current_session.state_string}.yml")

        begin
          File.read(reply_file_path)
        rescue Errno::ENOENT
          raise(Stealth::Errors::ReplyNotFound, "Could not find a reply in #{reply_file_path}")
        end
      end

      def update_session(flow:, state:)
        @current_session = Stealth::Session.new(user_id: current_user_id)
        @current_session.set(flow: flow, state: state)
      end

      def step(flow:, state:)
        update_session(flow: flow, state: state)
        @current_flow = current_session.flow

        action(action: state)
      end

      def get_flow_and_state(session: nil, flow: nil, state: nil)
        if session.nil? && flow.nil? && state.nil?
          raise(ArgumentError, "A session, flow, or state must be specified")
        end

        if session.present?
          return session.flow_string, session.state_string
        end

        if flow.present?
          if state.blank?
            flow_klass = [flow, 'flow'].join('_').classify.constantize
            state = flow_klass.flow_spec.states.keys.first
          end

          return flow, state
        end

        if state.present?
          return current_session.flow_string, state
        end
      end

      def get_next_state
        current_state_index = current_session.flow.states.index(current_session.state_string.to_sym)
        next_state = current_session.flow.states[current_state_index + 1]
        if next_state.nil?
          raise(
            Stealth::Errors::InvalidStateTransitions,
            "The next state after #{current_session.state_string} has not yet been defined"
          )
        end

        return current_session.flow_string, next_state
      end

  end
end
