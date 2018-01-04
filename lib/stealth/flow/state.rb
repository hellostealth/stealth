# coding: utf-8
# frozen_string_literal: true

module Stealth
  module Flow
    class State

      include Comparable

      attr_accessor :name, :events, :meta, :on_entry, :on_exit
      attr_reader :spec

      def initialize(name, spec, meta = {})
        @name, @spec, @events, @meta = name, spec, EventCollection.new, meta
      end

      def <=>(other_state)
        states = spec.states.keys
        raise ArgumentError, "state `#{other_state}' does not exist" unless states.include?(other_state.to_sym)
        states.index(self.to_sym) <=> states.index(other_state.to_sym)
      end

      def to_s
        "#{name}"
      end

      def to_sym
        name.to_sym
      end
    end
  end
end
