module Stealth
  class Controller < ApplicationController

    include Stealth::Controller::InterruptDetect

    attr_reader :current_message, :current_service, :current_session_id
    attr_accessor :nlp_result, :pos

    def initialize(service_event:, pos: nil)
      super()
      @current_message = service_event
      @current_service = service_event.service
      @current_session_id = service_event.sender_id
      # @nlp_result = service_event.nlp_result
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

    def flow_controller
      @flow_controller ||= begin
        flow_controller = [current_session.flow_string, 'controller'].join('_').classify.constantize
        flow_controller.new(service_message: @current_message, pos: @pos)
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
      begin
        # Grab a mutual exclusion lock on the session
        lock_session!(
          session_slug: Session.slugify(
            flow: current_session.flow_string,
            state: current_session.state_string
          )
        )

        @action_name = action
        @action_name ||= current_session.state_string

        # Check if the user needs to be redirected
        if current_session.flow.current_state.redirects_to.present?
          Stealth::Logger.l(
            topic: "redirect",
            message: "From #{current_session.session} to #{current_session.flow.current_state.redirects_to.session}"
          )
          step_to(session: current_session.flow.current_state.redirects_to, pos: @pos)
          return
        end

        run_callbacks :action do
          begin
            flow_controller.send(@action_name)
            unless flow_controller.progressed?
              run_catch_all(reason: 'Did not send replies, update session, or step')
            end
          rescue Stealth::Errors::Halted
            Stealth::Logger.l(
              topic: "session",
              message: "User #{current_session_id}: session halted."
            )
          rescue StandardError => e
            if e.class == Stealth::Errors::UnrecognizedMessage
              run_unrecognized_message(err: e)
            else
              run_catch_all(err: e)
            end
          end
        end
      ensure
        # Release mutual exclusion lock on the session
        release_lock!
      end
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

      Stealth::ScheduledReplyJob.perform_in(delay, current_service, current_session_id, flow, state, current_message.target_id)
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

      Stealth::ScheduledReplyJob.perform_at(timestamp, current_service, current_session_id, flow, state, current_message.target_id)
      Stealth::Logger.l(topic: "session", message: "User #{current_session_id}: scheduled session step to #{flow}->#{state} at #{timestamp.iso8601}")
    end

    def step_to(session: nil, flow: nil, state: nil, slug: nil, pos: nil)
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
      step(flow: flow, state: state, pos: pos)
    end

    def update_session_to(session: nil, flow: nil, state: nil, slug: nil)
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
        @current_session = Session.new(id: current_session_id)

        unless current_session.flow_string == flow.to_s && current_session.state_string == state.to_s
          @current_session.set_session(new_flow: flow, new_state: state)
        end

        Stealth.trigger_flow(flow, state)
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
        @progressed = :stepped
        @flow_controller = nil
        @current_flow = current_session.flow
        @pos = pos

        flow_controller.action(action: state)
      end

      def get_flow_and_state(session: nil, flow: nil, state: nil, slug: nil)
        if session.nil? && flow.nil? && state.nil? && slug.nil?
          raise(ArgumentError, "A session, flow, state, or slug must be specified")
        end

        if session.present?
          puts "session: #{session.inspect}"
          return session.flow_string, session.state_string
        end

        if slug.present?
          flow_state = Session.flow_and_state_from_session_slug(slug: slug)
          return flow_state[:flow], flow_state[:state]
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

  end
end
