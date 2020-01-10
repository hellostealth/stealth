# frozen_string_literal: true

require 'spec_helper'

describe Stealth::Flow::State do

  class SuperFlowMap
    include Stealth::Flow

    flow :new_todo do
      state :new
      state :get_due_date
      state :created, fails_to: :new
      state :created2, fails_to: 'new_todo->new'
      state :deprecated, redirects_to: 'new'
      state :deprecated2, redirects_to: 'other_flow->say_hi'
      state :error
    end
  end

  let(:flow_map) { SuperFlowMap.new }

  describe "flow states" do
    it "should convert itself to a string" do
      expect(flow_map.current_state.to_s).to be_a(String)
    end

    it "should convert itself to a symbol" do
      expect(flow_map.current_state.to_sym).to be_a(Symbol)
    end
  end

  describe "fails_to" do
    it "should be nil for a state that has not specified a fails_to" do
      expect(flow_map.current_state.fails_to).to be_nil
    end

    it "should return the fail_state if a fails_to was specified" do
      flow_map.init(flow: :new_todo, state: :created)
      expect(flow_map.current_state.fails_to).to be_a(Stealth::Session)
      expect(flow_map.current_state.fails_to.state_string).to eq 'new'
    end

    it "should return the fail_state if a fails_to was specified as a session" do
      flow_map.init(flow: :new_todo, state: :created2)
      expect(flow_map.current_state.fails_to).to be_a(Stealth::Session)
      expect(flow_map.current_state.fails_to.state_string).to eq 'new'
      expect(flow_map.current_state.fails_to.flow_string).to eq 'new_todo'
    end
  end

  describe "redirects_to" do
    it "should be nil for a state that has not specified a fails_to" do
      expect(flow_map.current_state.redirects_to).to be_nil
    end

    it "should return the redirects_to state if a redirects_to was specified" do
      flow_map.init(flow: :new_todo, state: :deprecated)
      expect(flow_map.current_state.redirects_to).to be_a(Stealth::Session)
      expect(flow_map.current_state.redirects_to.state_string).to eq 'new'
    end

    it "should return the redirects_to state if a redirects_to was specified as a session" do
      flow_map.init(flow: :new_todo, state: :deprecated2)
      expect(flow_map.current_state.redirects_to).to be_a(Stealth::Session)
      expect(flow_map.current_state.redirects_to.state_string).to eq 'say_hi'
      expect(flow_map.current_state.redirects_to.flow_string).to eq 'other_flow'
    end
  end

  describe "state incrementing and decrementing" do
    it "should increment the state" do
      flow_map.init(flow: :new_todo, state: :get_due_date)
      new_state = flow_map.current_state + 1.state
      expect(new_state).to eq(:created)
    end

    it "should decrement the state" do
      flow_map.init(flow: :new_todo, state: :error)
      new_state = flow_map.current_state - 5.states
      expect(new_state).to eq(:get_due_date)
    end

    it "should return the first state if the decrement is out of bounds" do
      flow_map.init(flow: :new_todo, state: :get_due_date)
      new_state = flow_map.current_state - 5.states
      expect(new_state).to eq(:new)
    end

    it "should return the last state if the increment is out of bounds" do
      flow_map.init(flow: :new_todo, state: :created)
      new_state = flow_map.current_state + 10.states
      expect(new_state).to eq(:error)
    end
  end

end
