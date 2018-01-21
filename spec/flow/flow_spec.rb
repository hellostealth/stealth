# coding: utf-8
# frozen_string_literal: true

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Stealth::Flow do

  class NewTodoFlow
    include Stealth::Flow

    flow do
      state :new

      state :get_due_date

      state :created

      state :error
    end
  end

  let(:flow) { NewTodoFlow.new }

  describe "inititating with states" do
    it "should init a state given a state name" do
      flow.init_state(:created)
      expect(flow.current_state).to eq :created

      flow.init_state('error')
      expect(flow.current_state).to eq :error
    end

    it "should raise an error if an invalid state is specified" do
      expect {
        flow.init_state(:invalid)
      }.to raise_error(Stealth::Errors::InvalidStateTransition)
    end
  end

  describe "accessing states" do
    it "should start out in the initial state" do
      expect(flow.current_state).to eq :new
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
