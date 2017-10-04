# coding: utf-8
# frozen_string_literal: true

require 'stealth/flow/errors'
require 'stealth/flow/specification'
require 'stealth/flow/event_collection'
require 'stealth/flow/event'
require 'stealth/flow/state'

module Stealth
  module Flow

    module ClassMethods
      attr_reader :flow_spec

      def flow(&specification)
        assign_flow Specification.new(Hash.new, &specification)
      end

      private

      # Creates the convinience methods like `my_transition!`
      def assign_flow(specification_object)

        # Merging two workflow specifications can **not** be done automically, so
        # just make the latest specification win. Same for inheritance -
        # definition in the subclass wins.
        if respond_to? :inherited_flow_spec # undefine methods defined by the old flow_spec
          inherited_flow_spec.states.values.each do |state|
            state_name = state.name
            module_eval do
              undef_method "#{state_name}?"
            end

            state.events.flat.each do |event|
              event_name = event.name
              module_eval do
                undef_method "#{event_name}!".to_sym
                undef_method "can_#{event_name}?"
              end
            end
          end
        end

        @flow_spec = specification_object
        @flow_spec.states.values.each do |state|
          state_name = state.name
          module_eval do
            define_method "#{state_name}?" do
              state_name == current_state.name
            end
          end

          state.events.flat.each do |event|
            event_name = event.name
            module_eval do
              define_method "#{event_name}!".to_sym do |*args|
                process_event!(event_name, *args)
              end

              define_method "can_#{event_name}?" do
                return !!current_state.events.first_applicable(event_name, self)
              end
            end
          end
        end
      end
    end

    module InstanceMethods
      attr_accessor :flow_state

      def current_state
        loaded_state = load_flow_state
        res = spec.states[loaded_state.to_sym] if loaded_state
        res || spec.initial_state
      end

      # Return true if the last transition was halted by one of the transition callbacks.
      def halted?
        @halted
      end

      # Return the reason of the last transition abort as set by the previous
      # call of `halt` or `halt!` method.
      def halted_because
        @halted_because
      end

      def process_event!(name, *args)
        event = current_state.events.first_applicable(name, self)
        raise NoTransitionAllowed.new(
          "There is no event #{name.to_sym} defined for the #{current_state} state") \
          if event.nil?
        @halted_because = nil
        @halted = false

        check_transition(event)

        from = current_state
        to = spec.states[event.transitions_to]

        run_before_transition(from, to, name, *args)
        return false if @halted

        begin
          return_value = run_action(event.action, *args) || run_action_callback(event.name, *args)
        rescue StandardError => e
          run_on_error(e, from, to, name, *args)
        end

        return false if @halted

        run_on_transition(from, to, name, *args)

        run_on_exit(from, to, name, *args)

        transition_value = persist_flow_state(to.to_s)

        run_on_entry(to, from, name, *args)

        run_after_transition(from, to, name, *args)

        return_value.nil? ? transition_value : return_value
      end

      def halt(reason = nil)
        @halted_because = reason
        @halted = true
      end

      def halt!(reason = nil)
        @halted_because = reason
        @halted = true
        raise TransitionHalted.new(reason)
      end

      def spec
        # check the singleton class first
        class << self
          return flow_spec if flow_spec
        end

        c = self.class
        # using a simple loop instead of class_inheritable_accessor to avoid
        # dependency on Rails' ActiveSupport
        until c.flow_spec || !(c.include? Stealth::Flow)
          c = c.superclass
        end
        c.flow_spec
      end

      private

      def check_transition(event)
        # Create a meaningful error message instead of
        # "undefined method `on_entry' for nil:NilClass"
        # Reported by Kyle Burton
        if !spec.states[event.transitions_to]
          raise StealthFlowError.new("Event[#{event.name}]'s " +
              "transitions_to[#{event.transitions_to}] is not a declared state.")
        end
      end

      def run_before_transition(from, to, event, *args)
        instance_exec(from.name, to.name, event, *args, &spec.before_transition_proc) if spec.before_transition_proc
      end

      def run_on_error(error, from, to, event, *args)
        if spec.on_error_proc
          instance_exec(error, from.name, to.name, event, *args, &spec.on_error_proc)
          halt(error.message)
        else
          raise error
        end
      end

      def run_on_transition(from, to, event, *args)
        instance_exec(from.name, to.name, event, *args, &spec.on_transition_proc) if spec.on_transition_proc
      end

      def run_after_transition(from, to, event, *args)
        instance_exec(from.name, to.name, event, *args, &spec.after_transition_proc) if spec.after_transition_proc
      end

      def run_action(action, *args)
        instance_exec(*args, &action) if action
      end

      def has_callback?(action)
        # 1. public callback method or
        # 2. protected method somewhere in the class hierarchy or
        # 3. private in the immediate class (parent classes ignored)
        action = action.to_sym
        self.respond_to?(action) or
          self.class.protected_method_defined?(action) or
          self.private_methods(false).map(&:to_sym).include?(action)
      end

      def run_action_callback(action_name, *args)
        action = action_name.to_sym
        self.send(action, *args) if has_callback?(action)
      end

      def run_on_entry(state, prior_state, triggering_event, *args)
        if state.on_entry
          instance_exec(prior_state.name, triggering_event, *args, &state.on_entry)
        else
          hook_name = "on_#{state}_entry"
          self.send hook_name, prior_state, triggering_event, *args if has_callback?(hook_name)
        end
      end

      def run_on_exit(state, new_state, triggering_event, *args)
        if state
          if state.on_exit
            instance_exec(new_state.name, triggering_event, *args, &state.on_exit)
          else
            hook_name = "on_#{state}_exit"
            self.send hook_name, new_state, triggering_event, *args if has_callback?(hook_name)
          end
        end
      end

      def load_flow_state
        @flow_state
      end

      def persist_flow_state(new_value)
        @flow_state = new_value
      end
    end

    def self.included(klass)
      klass.send :include, InstanceMethods
      klass.extend ClassMethods
    end
  end
end
