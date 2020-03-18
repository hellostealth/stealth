# frozen_string_literal: true

require 'spec_helper'

describe "Stealth::Controller::CatchAll" do
  $msg = nil

  class StubbedCatchAllsController < Stealth::Controller
    def level1
      $msg = current_message
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
      state :action_with_unrecognized_msg
      state :action_with_unrecognized_match
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

    it "should NOT run the catch_all if do_nothing is called" do
      controller.current_session.set_session(new_flow: 'vader', new_state: 'my_action3')
      controller.action(action: :my_action3)
      expect($redis.get(controller.current_session.session_key)).to eq('vader->my_action3')
    end

    describe "catch_alls from within catch_all flow" do
      let(:e) {
        e = OpenStruct.new
        e.class = RuntimeError
        e.message = 'oops'
        e.backtrace = [
          '/stealth/lib/stealth/controller/controller.rb',
          '/stealth/lib/stealth/controller/catch_all.rb',
        ]
        e
      }

      before(:each) do
        controller.current_session.session = Stealth::Session.canonical_session_slug(flow: 'catch_all', state: 'level1')
      end

      it "should not step_to to catch_all" do
        expect(controller).to_not receive(:step_to)
        controller.run_catch_all(err: e)
      end

      it "should return false" do
        expect(controller.run_catch_all(err: e)).to be false
      end

      it "should log the error message" do
        expect(Stealth::Logger).to receive(:l).with(topic: 'catch_all', message: "[Level 1] oops\n/stealth/lib/stealth/controller/controller.rb\n/stealth/lib/stealth/controller/catch_all.rb")
        expect(Stealth::Logger).to receive(:l).with(topic: 'catch_all', message: 'CatchAll triggered from within CatchAll; ignoring.')
        controller.run_catch_all(err: e)
      end
    end

    describe "catch_all_reason" do
      before(:each) do
        @session = Stealth::Session.new(id: controller.current_session_id)
        @session.set_session(new_flow: 'vader', new_state: 'my_action2')
      end

      after(:each) do
        $msg = nil
      end

      it 'should have access to the error raised in current_message.catch_all_reason' do
        controller.action(action: :my_action)
        expect($msg.catch_all_reason).to be_a(Hash)
        expect($msg.catch_all_reason[:err]).to eq(RuntimeError)
        expect($msg.catch_all_reason[:err_msg]).to eq('oops')
      end

      it 'should have the correct error when handle_message fails to recognize a message' do
        controller.action(action: :action_with_unrecognized_msg)
        expect($msg.catch_all_reason[:err]).to eq(Stealth::Errors::UnrecognizedMessage)
        expect($msg.catch_all_reason[:err_msg]).to eq("The reply '#{facebook_message.message_with_text.message}' was not recognized.")
      end

      it 'should have the correct error when get_match fails to recognize a message' do
        controller.action(action: :action_with_unrecognized_match)
        expect($msg.catch_all_reason[:err]).to eq(Stealth::Errors::UnrecognizedMessage)
        expect($msg.catch_all_reason[:err_msg]).to eq("The reply '#{facebook_message.message_with_text.message}' was not recognized.")
      end
    end
  end
end
