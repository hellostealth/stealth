# coding: utf-8
# frozen_string_literal: true

module Stealth
  module Flow
    class State

      include Comparable

      attr_accessor :name
      attr_reader :spec

      def initialize(name, spec)
        @name, @spec = name, spec
      end

      def <=>(other_state)
        states = spec.states.keys

        unless states.include?(other_state.to_sym)
          raise(ArgumentError, "state `#{other_state}' does not exist")
        end

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
