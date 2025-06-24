module Stealth
  class Controller < ApplicationController

    include Stealth::Controller::DevJumps
    include Stealth::Controller::DynamicDelay
    include Stealth::Controller::IntentClassifier
    include Stealth::Controller::InterruptDetect
    include Stealth::Controller::Messages
    include Stealth::Controller::Nlp
    include Stealth::Controller::Replies
    include Stealth::Controller::CatchAll
    include Stealth::Controller::UnrecognizedMessage

    attr_reader :current_message, :current_service, :current_session_id
    attr_accessor :nlp_result, :pos, :current_session, :previous_session

    def initialize(service_event:, pos: nil)
      super()
      @current_message = service_event
      @current_service = service_event.service
      @current_session_id = service_event.sender_id
      @current_session = Stealth::Session.new(id: current_session_id)
      @previous_session = Stealth::Session.new(id: current_session_id, type: :previous)
      @pos = pos
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

    def step_to_in(delay, session: nil, flow: nil, state: nil, slug: nil)
      if interrupt_detected?
        run_interrupt_action
        return :interrupted
      end

      flow, state = get_flow_and_state(
        session: session,
        flow: flow,
        state: state,
        slug: slug
      )

      unless delay.is_a?(ActiveSupport::Duration)
        raise ArgumentError, "Please specify your step_to_in `delay` parameter using ActiveSupport::Duration, e.g. `1.day` or `5.hours`"
      end

      Stealth::Services::ScheduledReplyJob.perform_in(delay, current_service, current_session_id, flow, state, current_message.target_id)
      Stealth::Logger.l(topic: "session", message: "User #{current_session_id}: scheduled session step to #{flow}->#{state} in #{delay} seconds")
    end

    def step_to_at(timestamp, session: nil, flow: nil, state: nil, slug: nil)
      if interrupt_detected?
        run_interrupt_action
        return :interrupted
      end

      flow, state = get_flow_and_state(
        session: session,
        flow: flow,
        state: state,
        slug: slug
      )

      unless timestamp.is_a?(DateTime)
        raise ArgumentError, "Please specify your step_to_at `timestamp` parameter as a DateTime"
      end

      Stealth::Services::ScheduledReplyJob.perform_at(timestamp, current_service, current_session_id, flow, state, current_message.target_id)
      Stealth::Logger.l(topic: "session", message: "User #{current_session_id}: scheduled session step to #{flow}->#{state} at #{timestamp.iso8601}")
    end

    def step_to(session: nil, flow: nil, state: nil, slug: nil, pos: nil, locals: nil)
      if interrupt_detected?
        run_interrupt_action
        return :interrupted
      end

      flow, state = get_flow_and_state(
        session: session,
        flow: flow,
        state: state,
        slug: slug
      )
      current_session.locals = locals

      # Workaround for update_session_to.
      if previous_session.before_update_session_to_locals.present?
        current_session.locals = previous_session.before_update_session_to_locals
      end
      step(flow: flow, state: state, pos: pos)
    end

    def update_session_to(session: nil, flow: nil, state: nil, slug: nil, locals: nil)
      if interrupt_detected?
        run_interrupt_action
        return :interrupted
      end

      flow, state = get_flow_and_state(
        session: session,
        flow: flow,
        state: state,
        slug: slug
      )
      current_session.before_update_session_to_locals = locals
      update_session(flow: flow, state: state)
    end

    def set_back_to(session: nil, flow: nil, state: nil, slug: nil)
      if interrupt_detected?
        run_interrupt_action
        return :interrupted
      end

      flow, state = get_flow_and_state(
        session: session,
        flow: flow,
        state: state,
        slug: slug
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
    end

    def halt!
      raise Stealth::Errors::Halted
    end

    private

      def update_session(flow:, state:)
        @progressed = :updated_session

        current_session.set_session(new_flow: flow, new_state: state)
      end

      def store_back_to_session(flow:, state:)
        back_to_session = Session.new(
          id: current_session_id,
          type: :back_to
        )
        back_to_session.set_session(new_flow: flow, new_state: state)
      end

      def step(flow:, state:, pos: nil)
        update_session(flow: flow, state: state)

        begin
          # Grab a mutual exclusion lock on the session
          lock_session!(
            session_slug: Stealth::Session.slugify(flow: flow, state: state)
          )

          Stealth.trigger_flow(flow, state, @current_message)

          @progressed = :stepped
          @pos = pos
        rescue Stealth::Errors::Halted
          Stealth::Logger.l(
            topic: "session",
            message: "User #{current_session_id}: session halted."
          )
        rescue StandardError => e
          if e.is_a?(Stealth::Errors::UnrecognizedMessage)
            run_unrecognized_message(err: e)
          else
            run_catch_all(err: e)
          end
        ensure
          release_lock!
        end
      end

      def get_flow_and_state(session: nil, flow: nil, state: nil, slug: nil)
        if session.nil? && flow.nil? && state.nil? && slug.nil?
          raise(ArgumentError, "A session, flow, state, or slug must be specified")
        end

        if session.present?
          return session.flow_string, session.state_string
        end

        if slug.present?
          flow_state = Session.flow_and_state_from_session_slug(slug: slug)
          return flow_state[:flow], flow_state[:state]
        end

        if flow.present?

          if state.blank?
            # Access the existing FlowManager instance that has the registered flows
            flow_manager = Stealth::FlowManager.instance

            # Retrieve the flow states for the specified flow
            flow_states = flow_manager.instance_variable_get(:@flows)[flow.to_sym]

            if flow_states.present?
              state = flow_states[:states].keys.first.to_s
            else
              raise ArgumentError, "No states defined for flow: #{flow}"
            end
          end

          return flow.to_s, state.to_s
        end

        if state.present?
          return current_session.flow_string, state.to_s
        end
      end
  end
end
