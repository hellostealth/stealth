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

      def draw(graph)
        defaults = {
          :label => to_s,
          :width => '1',
          :height => '1',
          :shape => 'ellipse'
        }

        node = graph.add_nodes(to_s, defaults.merge(meta))

        # Add open arrow for initial state
        # graph.add_edge(graph.add_node('starting_state', :shape => 'point'), node) if initial?

        node
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
