# coding: utf-8
# frozen_string_literal: true

module Stealth
  class Controller

    include Stealth::Controller::Callbacks
    include Stealth::Controller::Replies
    include Stealth::Controller::CatchAll
    include Stealth::Controller::Helpers

    attr_reader :current_message, :current_user_id, :current_flow,
                :current_service, :flow_controller, :action_name

    def initialize(service_message:, current_flow: nil)
      @current_message = service_message
      @current_service = service_message.service
      @current_user_id = service_message.sender_id
      @current_flow = current_flow
      @progressed = false
    end

    def has_location?
      current_message.location.present?
    end

    def has_attachments?
      current_message.attachments.present?
    end

    def progressed?
      @progressed.present?
    end

    def route
      raise(Stealth::Errors::ControllerRoutingNotImplemented, "Please implement `route` method in BotController")
    end

    def flow_controller
      @flow_controller ||= begin
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

    def previous_session
      @previous_session ||= Stealth::Session.new(user_id: current_user_id, previous: true)
    end

    def action(action: nil)
      @action_name = action
      @action_name ||= current_session.state_string

      run_callbacks :action do
        begin
          flow_controller.send(@action_name)
          run_catch_all(reason: 'Did not send replies, update session, or step') unless flow_controller.progressed?
        rescue StandardError => e
          Stealth::Logger.l(topic: "catch_all", message: e.backtrace)
          run_catch_all(reason: e.message)
        end
      end
    end

    def step_to_in(delay, session: nil, flow: nil, state: nil)
      flow, state = get_flow_and_state(session: session, flow: flow, state: state)

      unless delay.is_a?(ActiveSupport::Duration)
        raise ArgumentError, "Please specify your step_to_in `delay` parameter using ActiveSupport::Duration, e.g. `1.day` or `5.hours`"
      end

      Stealth::ScheduledReplyJob.perform_in(delay, current_service, current_user_id, flow, state)
      Stealth::Logger.l(topic: "session", message: "User #{current_user_id}: scheduled session step to #{flow}->#{state} in #{delay} seconds")
    end

    def step_to(session: nil, flow: nil, state: nil)
      flow, state = get_flow_and_state(session: session, flow: flow, state: state)
      step(flow: flow, state: state)
    end

    def update_session_to(session: nil, flow: nil, state: nil)
      flow, state = get_flow_and_state(session: session, flow: flow, state: state)
      update_session(flow: flow, state: state)
    end

    private

      def update_session(flow:, state:)
        Stealth::Logger.l(topic: "session", message: "User #{current_user_id}: updating session to #{flow}->#{state}")

        @current_session = Stealth::Session.new(user_id: current_user_id)
        @progressed = :updated_session
        @current_session.set(flow: flow, state: state)
      end

      def step(flow:, state:)
        Stealth::Logger.l(topic: "session", message: "User #{current_user_id}: stepping to #{flow}->#{state}")

        update_session(flow: flow, state: state)
        @progressed = :stepped
        @flow_controller = nil
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
            flow_klass = [flow.to_s, 'flow'].join('_').classify.constantize
            state = flow_klass.flow_spec.states.keys.first.to_s
          end

          return flow.to_s, state.to_s
        end

        if state.present?
          return current_session.flow_string, state.to_s
        end
      end

  end
end
