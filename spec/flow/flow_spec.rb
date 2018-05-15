# coding: utf-8
# frozen_string_literal: true

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Stealth::Flow do

  class CustomFlowMap
    include Stealth::Flow

    flow :new_todo do
      state :new
      state :get_due_date
      state :created
      state :error
    end

    flow :hello do
      state :say_hello
      state :say_oi
    end

    flow "howdy" do
      state :say_howdy
    end
  end

  let(:flow_map) { CustomFlowMap.new }

  describe "inititating with states" do
    it "should init a state given a state name" do
      flow_map.init(flow: 'new_todo', state: 'created')
      expect(flow_map.current_state).to eq :created

      flow_map.init(flow: 'new_todo', state: 'error')
      expect(flow_map.current_state).to eq :error
    end

    it "should raise an error if an invalid state is specified" do
      expect {
        flow_map.init(flow: 'new_todo', state: 'invalid')
      }.to raise_error(Stealth::Errors::InvalidStateTransition)
    end
  end

  describe "accessing states" do
    it "should default to the first flow and state" do
      expect(flow_map.current_flow).to eq(:new_todo)
      expect(flow_map.current_state).to eq(:new)
    end

    it "should support comparing states" do
      first_state = CustomFlowMap.flow_spec[:new_todo].states[:new]
      last_state = CustomFlowMap.flow_spec[:new_todo].states[:error]
      expect(first_state < last_state).to be true
      expect(last_state > first_state).to be true
    end

    it "should allow every state to be fetched for a flow" do
      expect(CustomFlowMap.flow_spec[:new_todo].states.length).to eq 4
      expect(CustomFlowMap.flow_spec[:hello].states.length).to eq 2
      expect(CustomFlowMap.flow_spec[:new_todo].states.keys).to eq([:new, :get_due_date, :created, :error])
      expect(CustomFlowMap.flow_spec[:hello].states.keys).to eq([:say_hello, :say_oi])
    end

    it "should return the states in an array for a given FlowMap instance" do
      expect(flow_map.states).to eq [:new, :get_due_date, :created, :error]
      flow_map.init(flow: :hello, state: :say_oi)
      expect(flow_map.states).to eq [:say_hello, :say_oi]
    end

    it "should allow flows to be specified with strings" do
      expect(CustomFlowMap.flow_spec[:howdy].states.length).to eq 1
      expect(CustomFlowMap.flow_spec[:howdy].states.keys).to eq([:say_howdy])
    end

    it "should allow FlowMaps to be intialized with strings" do
      flow_map.init(flow: "hello", state: "say_oi")
      expect(flow_map.states).to eq [:say_hello, :say_oi]
    end
  end

end
