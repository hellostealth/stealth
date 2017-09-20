# frozen_string_literal: true

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "transition callbacks" do

  class KonamiCodeFlow
    include Stealth::Flow

    attr_reader :code, :before_transition_count, :transition_count

    def initialize
      @code = []
      @before_transition_count = 0
      @transition_count = 0
    end

    flow do
      state :up do
        event :upward, :transitions_to => :up
        event :downward, :transitions_to => :down
      end

      state :down do
        event :downward, :transitions_to => :down
        event :leftward, :transitions_to => :left
      end

      state :left do
        event :rightward, :transitions_to => :right
      end

      state :right do
        event :leftward, :transitions_to => :left
        event :bward, :transitions_to => :b
      end

      state :a

      state :b do
        event :award, :transitions_to => :a
      end

      before_transition do |from, to, triggering_event, *event_args|
        @before_transition_count += 1
      end

      after_transition do |from, to, triggering_event, *event_args|
        @code << to.to_s
      end

      on_transition {
        @transition_count += 1
      }
    end
  end

  let(:flow) { KonamiCodeFlow.new }

  before(:each) do
    flow.upward!
    flow.upward!
    flow.downward!
    flow.downward!
    flow.leftward!
    flow.rightward!
    flow.leftward!
    flow.rightward!
    flow.bward!
    flow.award!
  end

  it "should have a correct transition count" do
    expect(flow.transition_count).to eq 10
  end

  it "should have a correct before_transition count" do
    expect(flow.before_transition_count).to eq 10
  end

  it "should have generated the correct code via after_transition" do
    expect(flow.code).to eq(['up', 'up', 'down', 'down', 'left', 'right', 'left', 'right', 'b', 'a'])
  end

  describe "on_error callbacks" do
    class ErrorFlow
      include Stealth::Flow

      attr_reader :errors

      def initialize
        @errors = {}
      end

      flow do
        state :first do
          event :advance, :transitions_to => :second do
            raise "uh oh"
          end
        end

        state :second

        on_error do |error, from, to, event, *args|
          @errors.merge!({
            error: error.class,
            from: from,
            to: to,
            event: event,
            args: args
          })
        end
      end
    end

    let(:error_flow) { ErrorFlow.new }

    it "should not advance to the next state" do
      error_flow.advance!
      expect(error_flow.current_state).to eq :first
    end

    it "should call the on_error block" do
      error_flow.advance!
      expect(error_flow.errors).to eq({ error: RuntimeError, from: :first, to: :second, event: :advance, args: [] })
    end
  end

end
