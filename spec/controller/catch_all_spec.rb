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
      do_nothing
    end
  end

  class StubbedCatchAllsController < Stealth::Controller
    def level1
      do_nothing
    end

    def level2
      do_nothing
    end

    def level3
      do_nothing
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
      controller.current_session.session = Stealth::Session.canonical_session_slug(flow: 'vader', state: 'my_action')
      controller.action(action: :my_action)
      expect($redis.get(controller.current_session.session_key)).to eq('catch_all->level1')
    end

    it "should step_to catch_all->level1 when an action doesn't progress the flow" do
      controller.current_session.session = Stealth::Session.canonical_session_slug(flow: 'vader', state: 'my_action2')
      controller.action(action: :my_action2)
      expect($redis.get(controller.current_session.session_key)).to eq('catch_all->level1')
    end

    it "should step_to catch_all->level2 when an action raises back to back" do
      controller.step_to flow: :vader, state: :my_action
      controller.step_to flow: :vader, state: :my_action
      expect($redis.get(controller.current_session.session_key)).to eq('catch_all->level2')
    end

    it "should step_to catch_all->level3 when an action raises back to back to back" do
      controller.step_to flow: :vader, state: :my_action
      controller.step_to flow: :vader, state: :my_action
      controller.step_to flow: :vader, state: :my_action
      expect($redis.get(controller.current_session.session_key)).to eq('catch_all->level3')
    end

    it "should just stop after the maximum number of catch_all levels have been reached" do
      controller.step_to flow: :vader, state: :my_action
      controller.step_to flow: :vader, state: :my_action
      controller.step_to flow: :vader, state: :my_action
      controller.step_to flow: :vader, state: :my_action
      expect($redis.get(controller.current_session.session_key)).to eq('vader->my_action')
    end

    it "should release the session lock after the maximum number of catch_all levels have been reached" do
      allow(controller).to receive(:fetch_error_level).and_return(1, 2, 3, 4)
      session = Stealth::Session.new(id: controller.current_session_id)
      session.set_session(new_flow: 'vader', new_state: 'my_action')
      expect(controller).to receive(:release_lock!)
      controller.run_catch_all
      controller.run_catch_all
      controller.run_catch_all
      controller.run_catch_all
    end

    it "should release the session lock if the bot does not have a CatchAll flow" do
      FlowMap.flow_spec[:catch_all] = nil
      expect(controller).to receive(:release_lock!)
      controller.run_catch_all
    end

    it "should NOT run the catch_all if do_nothing is called" do
      controller.current_session.set_session(new_flow: 'vader', new_state: 'my_action3')
      controller.action(action: :my_action3)
      expect($redis.get(controller.current_session.session_key)).to eq('vader->my_action3')
    end
  end
end
