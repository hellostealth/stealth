# frozen_string_literal: true

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Stealth::Flow do

  class NewTodoFlow
    include Stealth::Flow

    flow do
      state :new do
        event :submit_todo, :transitions_to => :get_due_date
        event :error_in_input, :transitions_to => :error
      end

      state :get_due_date do
        event :submit_due_date, :transitions_to => :created
      end

      state :created

      state :error do
        event :submit_todo, :transitions_to => :get_due_date
        event :error_in_input, :transitions_to => :error
      end
    end
  end

  let(:flow) { NewTodoFlow.new }

  describe "state transitions" do
    it "should start out in the 'new' state" do
      expect(flow.current_state).to eq :new
    end

    it "should transition into the 'get_due_date' state after submit" do
      flow.submit_todo!
      expect(flow.current_state).to eq :get_due_date
    end

    it "should transition into the 'error' state after error_in_input" do
      flow.error_in_input!
      expect(flow.current_state).to eq :error
    end

    it "should transition through multiple states" do
      flow.submit_todo!
      flow.submit_due_date!
      expect(flow.current_state).to eq :created
    end

    it "should remain in the error state" do
      flow.error_in_input!
      expect(flow.current_state).to eq :error
      flow.error_in_input!
      expect(flow.current_state).to eq :error
    end

    it "should be false when checking the possibility of a non-valid transition" do
      expect(flow.can_submit_due_date?).to be false
    end

    it "should be false when checking the possibility of a valid transition" do
      flow.submit_todo!
      expect(flow.can_submit_due_date?).to be true
    end
  end

  describe "accessing states" do
    it "should start out in the 'new' state" do
      expect(flow.new?).to be true
    end

    it "should support comparing states" do
      first_state = NewTodoFlow.flow_spec.states[:new]
      last_state = NewTodoFlow.flow_spec.states[:error]
      expect(first_state < last_state).to be true
      expect(last_state > first_state).to be true
    end

    it "should allow every state to be fetched for the class" do
      expect(NewTodoFlow.flow_spec.states.length).to eq 4
      expect(NewTodoFlow.flow_spec.states.keys).to eq([:new, :get_due_date, :created, :error])
    end

    it "should return the states in an array for a given flow instance" do
      expect(flow.states).to eq [:new, :get_due_date, :created, :error]
    end
  end

end
