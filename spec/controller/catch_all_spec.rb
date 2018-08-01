# coding: utf-8
# frozen_string_literal: true

require File.expand_path(File.join(File.dirname(__FILE__), '..', '/spec_helper'))

describe "Stealth::Controller::CatchAll" do

  class VadersController < Stealth::Controller
    def my_action
      raise "oops"
    end

    def my_action2

    end

    def my_action3

    end
  end

  class StubbedCatchAllsController < Stealth::Controller
    def level1

    end

    def level2

    end

    def level3

    end
  end

  class FlowMap
    include Stealth::Flow

    flow :vader do
      state :my_action
      state :my_action2
      state :my_action3
    end

    flow :catch_all do
      state :level1
      state :level2
      state :level3
    end
  end

  let(:facebook_message) { SampleMessage.new(service: 'facebook') }
  let(:controller) { VadersController.new(service_message: facebook_message.message_with_text) }

  describe "when a CatchAll flow is defined" do
    before(:each) do
      stub_const("CatchAllsController", StubbedCatchAllsController)
    end

    after(:each) do
      $redis.flushdb
    end

    it "should step_to catch_all->level1 when a StandardError is raised" do
      controller.action(action: :my_action)
      expect(controller.current_session.flow_string).to eq("catch_all")
      expect(controller.current_session.state_string).to eq("level1")
    end

    it "should step_to catch_all->level1 when an action doesn't progress the flow" do
      controller.action(action: :my_action2)
      expect(controller.current_session.flow_string).to eq("catch_all")
      expect(controller.current_session.state_string).to eq("level1")
    end

    it "should step_to catch_all->level2 when an action raises back to back" do
      controller.step_to flow: :vader, state: :my_action
      controller.step_to flow: :vader, state: :my_action
      expect(controller.current_session.flow_string).to eq("catch_all")
      expect(controller.current_session.state_string).to eq("level2")
    end

    it "should step_to catch_all->level3 when an action raises back to back to back" do
      controller.step_to flow: :vader, state: :my_action
      controller.step_to flow: :vader, state: :my_action
      controller.step_to flow: :vader, state: :my_action
      expect(controller.current_session.flow_string).to eq("catch_all")
      expect(controller.current_session.state_string).to eq("level3")
    end

    it "should just stop after the maximum number of catch_all levels have been reached" do
      controller.step_to flow: :vader, state: :my_action
      controller.step_to flow: :vader, state: :my_action
      controller.step_to flow: :vader, state: :my_action
      controller.step_to flow: :vader, state: :my_action
      expect(controller.current_session.flow_string).to eq("vader")
      expect(controller.current_session.state_string).to eq("my_action")
    end
  end
end

