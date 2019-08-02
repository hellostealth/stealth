# coding: utf-8
# frozen_string_literal: true

module Stealth
  class Controller

    include Stealth::Controller::Callbacks
    include Stealth::Controller::DynamicDelay
    include Stealth::Controller::Replies
    include Stealth::Controller::CatchAll
    include Stealth::Controller::Helpers

    attr_reader :current_message, :current_user_id, :current_flow,
                :current_service, :flow_controller, :action_name,
                :current_session_id

    def initialize(service_message:, current_flow: nil)
      @current_message = service_message
      @current_service = service_message.service
      @current_user_id = @current_session_id = service_message.sender_id
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
      @current_session ||= Stealth::Session.new(user_id: current_session_id)
    end

    def previous_session
      @previous_session ||= Stealth::Session.new(user_id: current_session_id, previous: true)
    end

    def action(action: nil)
      @action_name = action
      @action_name ||= current_session.state_string

      # Check if the user needs to be redirected
      if current_session.flow.current_state.redirects_to.present?
        Stealth::Logger.l(
          topic: "redirect",
          message: "From #{current_session.session} to #{current_session.flow.current_state.redirects_to.session}"
        )
        step_to(session: current_session.flow.current_state.redirects_to)
        return
      end

      run_callbacks :action do
        begin
          flow_controller.send(@action_name)
          unless flow_controller.progressed?
            run_catch_all(reason: 'Did not send replies, update session, or step')
          end
        rescue StandardError => e
          Stealth::Logger.l(topic: "catch_all", message: e.backtrace.join("\n"))
          run_catch_all(reason: e.message)
        end
      end
    end

    def step_to_in(delay, session: nil, flow: nil, state: nil, params: {})
      flow, state, params = get_flow_state_and_params(session: session, flow: flow, state: state, params: params)

      unless delay.is_a?(ActiveSupport::Duration)
        raise ArgumentError, "Please specify your step_to_in `delay` parameter using ActiveSupport::Duration, e.g. `1.day` or `5.hours`"
      end

      Stealth::ScheduledReplyJob.perform_in(delay, current_service, current_session_id, flow, state, params)
      Stealth::Logger.l(topic: "session", message: "User #{current_session_id}: scheduled session step to #{flow}->#{state}?#{params.to_h} in #{delay} seconds")
    end

    def step_to_at(timestamp, session: nil, flow: nil, state: nil, params: {})
      flow, state, params = get_flow_state_and_params(session: session, flow: flow, state: state, params: params)

      unless timestamp.is_a?(DateTime)
        raise ArgumentError, "Please specify your step_to_at `timestamp` parameter as a DateTime"
      end

      Stealth::ScheduledReplyJob.perform_at(timestamp, current_service, current_session_id, flow, state, params)
      Stealth::Logger.l(topic: "session", message: "User #{current_session_id}: scheduled session step to #{flow}->#{state}?#{params.to_h} at #{timestamp.iso8601}")
    end

    def step_to(session: nil, flow: nil, state: nil, params: {})
      flow, state, params = get_flow_state_and_params(session: session, flow: flow, state: state, params: params)
      step(flow: flow, state: state, params: params)
    end

    def update_session_to(session: nil, flow: nil, state: nil, params: {})
      flow, state, params = get_flow_state_and_params(session: session, flow: flow, state: state, params: params)
      update_session(flow: flow, state: state, params: params)
    end

    def do_nothing
      @progressed = :do_nothing
    end

    private

      def update_session(flow:, state:, params:)
        @current_session = Stealth::Session.new(user_id: current_session_id)
        @progressed = :updated_session
        @current_session.set(flow: flow, state: state, params: params)
      end

      def step(flow:, state:, params:)
        update_session(flow: flow, state: state, params: params)
        @progressed = :stepped
        @flow_controller = nil
        @current_flow = current_session.flow

        action(action: state)
      end

      def get_flow_state_and_params(session: nil, flow: nil, state: nil, params: {})
        if session.nil? && flow.nil? && state.nil?
          raise(ArgumentError, "A session, flow, or state must be specified")
        end

        if session.present?
          return session.flow_string, session.state_string, session.params
        end

        if flow.present?
          if state.blank?
            state = FlowMap.flow_spec[flow.to_sym].states.keys.first.to_s
          end

          return flow.to_s, state.to_s, params.to_h
        end

        if state.present?
          return current_session.flow_string, state.to_s, params.to_h
        end
      end

  end
end
