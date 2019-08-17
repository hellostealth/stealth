# coding: utf-8
# frozen_string_literal: true

module Stealth
  class Controller

    include Stealth::Controller::Callbacks
    include Stealth::Controller::DynamicDelay
    include Stealth::Controller::Replies
    include Stealth::Controller::CatchAll
    include Stealth::Controller::Helpers
    include Stealth::Controller::InterruptDetect

    attr_reader :current_message, :current_service, :flow_controller,
                :action_name, :current_session_id

    def initialize(service_message:)
      @current_message = service_message
      @current_service = service_message.service
      @current_session_id = service_message.sender_id
      @progressed = false
    end

    def has_location?
      current_message.location.present?
    end

    def has_attachments?
      current_message.attachments.present?
    end

    def progressed?
      @progressed
    end

    def route
      raise(Stealth::Errors::ControllerRoutingNotImplemented, "Please implement `route` method in BotController")
    end

    def flow_controller
      @flow_controller ||= begin
        flow_controller = [current_session.flow_string.pluralize, 'controller'].join('_').classify.constantize
        flow_controller.new(service_message: @current_message)
      end
    end

    def current_session
      @current_session ||= Stealth::Session.new(id: current_session_id)
    end

    def previous_session
      @previous_session ||= Stealth::Session.new(
        id: current_session_id,
        type: :previous
      )
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
          Stealth::Logger.l(
            topic: "catch_all",
            message: [e.message, e.backtrace.join("\n")].join("\n")
          )
          run_catch_all(reason: e.message)
        end
      end
    end

    def step_to_in(delay, session: nil, flow: nil, state: nil)
      if interrupt_detected?
        run_interrupt_action
        return :interrupted
      end

      flow, state = get_flow_and_state(session: session, flow: flow, state: state)

      unless delay.is_a?(ActiveSupport::Duration)
        raise ArgumentError, "Please specify your step_to_in `delay` parameter using ActiveSupport::Duration, e.g. `1.day` or `5.hours`"
      end

      Stealth::ScheduledReplyJob.perform_in(delay, current_service, current_session_id, flow, state, current_message.target_id)
      Stealth::Logger.l(topic: "session", message: "User #{current_session_id}: scheduled session step to #{flow}->#{state} in #{delay} seconds")
    end

    def step_to_at(timestamp, session: nil, flow: nil, state: nil)
      if interrupt_detected?
        run_interrupt_action
        return :interrupted
      end

      flow, state = get_flow_and_state(session: session, flow: flow, state: state)

      unless timestamp.is_a?(DateTime)
        raise ArgumentError, "Please specify your step_to_at `timestamp` parameter as a DateTime"
      end

      Stealth::ScheduledReplyJob.perform_at(timestamp, current_service, current_session_id, flow, state, current_message.target_id)
      Stealth::Logger.l(topic: "session", message: "User #{current_session_id}: scheduled session step to #{flow}->#{state} at #{timestamp.iso8601}")
    end

    def step_to(session: nil, flow: nil, state: nil)
      if interrupt_detected?
        run_interrupt_action
        return :interrupted
      end

      flow, state = get_flow_and_state(
        session: session,
        flow: flow,
        state: state
      )

      lock_session!(session_slug: Session.slugify(flow: flow, state: state))

      step(flow: flow, state: state)
    end

    def update_session_to(session: nil, flow: nil, state: nil)
      if interrupt_detected?
        run_interrupt_action
        return :interrupted
      end

      flow, state = get_flow_and_state(
        session: session,
        flow: flow,
        state: state
      )
      update_session(flow: flow, state: state)
      release_lock!
    end

    def set_back_to(session: nil, flow: nil, state:)
      if interrupt_detected?
        run_interrupt_action
        return :interrupted
      end

      flow, state = get_flow_and_state(
        session: session,
        flow: flow,
        state: state
      )
      store_back_to_session(flow: flow, state: state)
    end

    def step_back
      back_to_session = Stealth::Session.new(
        id: current_session_id,
        type: :back_to
      )

      if back_to_session.blank?
        raise(
          Stealth::Errors::InvalidStateTransition,
          'back_to_session not found; make sure set_back_to was called first'
        )
      end

      step_to(session: back_to_session)
    end

    def do_nothing
      @progressed = :do_nothing
      release_lock!
    end

    private

      def update_session(flow:, state:)
        @progressed = :updated_session
        @current_session = Stealth::Session.new(id: current_session_id)

        unless current_session.flow_string == flow.to_s && current_session.state_string == state.to_s
          @current_session.set_session(new_flow: flow, new_state: state)
        end
      end

      def store_back_to_session(flow:, state:)
        back_to_session = Stealth::Session.new(
          id: current_session_id,
          type: :back_to
        )
        back_to_session.set_session(new_flow: flow, new_state: state)
      end

      def step(flow:, state:)
        update_session(flow: flow, state: state)
        @progressed = :stepped
        @flow_controller = nil
        @current_flow = current_session.flow

        flow_controller.action(action: state)
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
            state = FlowMap.flow_spec[flow.to_sym].states.keys.first.to_s
          end

          return flow.to_s, state.to_s
        end

        if state.present?
          return current_session.flow_string, state.to_s
        end
      end

      def dev_jump_detected?
        if Stealth.env == 'development'
          if current_message.message&.match(/\/(.*)\/(.*)|\/\/(.*)|\/(.*)/)
            handle_dev_jump
            return true
          end
        end

        false
      end

      def handle_dev_jump
        _, flow, state = current_message.message.split('/')
        flow = nil if flow.blank?

        step_to flow: flow, state: state
      end

  end
end
