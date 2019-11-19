# coding: utf-8
# frozen_string_literal: true

require File.expand_path(File.join(File.dirname(__FILE__), '..', '/spec_helper'))

describe "Stealth::Controller" do

  class MrRobotsController < Stealth::Controller
    def my_action
      [:success, :my_action]
    end

    def my_action2
      [:success, :my_action2]
    end

    def my_action3
      [:success, :my_action3]
    end
  end

  class MrTronsController < Stealth::Controller
    def other_action

    end

    def other_action2

    end

    def other_action3

    end

    def other_action4
      do_nothing
    end
  end

  class FlowMap
    include Stealth::Flow

    flow :mr_robot do
      state :my_action
      state :my_action2
      state :my_action3
    end

    flow :mr_tron do
      state :other_action
      state :other_action2
      state :other_action3
      state :other_action4
      state :deprecated_action, redirects_to: :other_action
      state :deprecated_action2, redirects_to: 'mr_robot->my_action'
    end
  end

  let(:facebook_message) { SampleMessage.new(service: 'facebook') }
  let(:controller) {
    MrTronsController.new(service_message: facebook_message.message_with_text)
  }

  describe "convenience methods" do
    it "should make the session ID accessible via current_session_id" do
      controller.current_session.set_session(new_flow: 'mr_tron', new_state: 'other_action')

      expect(controller.current_session_id).to eq(facebook_message.sender_id)
    end

    it "should make the message available in current_message.message" do
      expect(controller.current_message.message).to eq(facebook_message.message)
    end

    it "should make the payload available in current_message.payload" do
      message_with_payload = facebook_message.message_with_payload
      expect(controller.current_message.payload).to eq(message_with_payload.payload)
    end

    describe "current_service" do
      let(:twilio_message) { SampleMessage.new(service: 'twilio') }
      let(:controller_with_twilio_message) { MrTronsController.new(service_message: twilio_message.message_with_text) }

      it "should detect a Facebook message" do
        expect(controller.current_service).to eq('facebook')
      end

      it "should detect a Twilio message" do
        expect(controller_with_twilio_message.current_service).to eq('twilio')
      end
    end

    describe "messages with location" do
      let(:message_with_location) { facebook_message.message_with_location }
      let(:controller_with_location) { MrTronsController.new(service_message: message_with_location) }

      it "should make the location available in current_message.location" do
        expect(controller_with_location.current_message.location).to eq(message_with_location.location)
      end

      it "should return true for current_message.has_location?" do
        expect(controller_with_location.has_location?).to be true
      end
    end

    describe "messages with attachments" do
      let(:message_with_attachments) { facebook_message.message_with_attachments }
      let(:controller_with_attachment) { MrTronsController.new(service_message: message_with_attachments) }

      it "should make the attachments available in current_message.attachments" do
        expect(controller_with_attachment.current_message.attachments).to eq(message_with_attachments.attachments)
      end

      it "should return true for current_message.has_attachments?" do
        expect(controller_with_attachment.has_attachments?).to be true
      end
    end
  end

  describe "states with redirect_to specified" do
    it "should step_to the specified redirect state when only a state is specified" do
      controller.current_session.session = Stealth::Session.canonical_session_slug(flow: 'mr_tron', state: 'deprecated_action')
      expect(MrTronsController).to receive(:new).and_return(controller)
      expect(controller).to receive(:other_action)
      controller.action(action: :deprecated_action)
    end

    it "should step_to the specified redirect flow and state when a session is specified" do
      controller.current_session.session = Stealth::Session.canonical_session_slug(flow: 'mr_tron', state: 'deprecated_action2')
      mr_robot_controller = MrRobotsController.new(service_message: facebook_message.message_with_text)

      allow(MrRobotsController).to receive(:new).and_return(mr_robot_controller)
      expect(mr_robot_controller).to receive(:my_action)
      controller.action(action: :deprecated_action2)
    end

    it "should NOT call the redirected controller action method" do
      controller.current_session.session = Stealth::Session.canonical_session_slug(flow: 'mr_tron', state: 'deprecated_action')
      expect(MrTronsController).to receive(:new).and_return(controller)
      expect(controller).to_not receive(:deprecated_action)
      controller.action(action: :deprecated_action)
    end
  end

  describe "step_to" do
    it "should raise an ArgumentError if a session, flow, or state is not specified" do
      expect {
        controller.step_to
      }.to raise_error(ArgumentError)
    end

    it "should call the flow's first state's controller action when only a flow is provided" do
      expect_any_instance_of(MrRobotsController).to receive(:my_action)
      controller.step_to flow: "mr_robot"
    end

    it "should call a controller's corresponding action when only a state is provided" do
      expect_any_instance_of(MrTronsController).to receive(:other_action3)

      controller.current_session.set_session(new_flow: 'mr_tron', new_state: 'other_action')

      controller.step_to state: "other_action3"
    end

    it "should call a controller's corresponding action when a state and flow is provided" do
      expect_any_instance_of(MrRobotsController).to receive(:my_action3)
      controller.step_to flow: "mr_robot", state: "my_action3"
    end

    it "should call a controller's corresponding action when a session is provided" do
      expect_any_instance_of(MrRobotsController).to receive(:my_action3)

      allow(controller.current_session).to receive(:flow_string).and_return("mr_robot")
      allow(controller.current_session).to receive(:state_string).and_return("my_action3")

      controller.step_to session: controller.current_session
    end

    it "should accept flow and string specified as symbols" do
      expect_any_instance_of(MrRobotsController).to receive(:my_action3)
      controller.step_to flow: :mr_robot, state: :my_action3
    end

    it "should lock the session" do
      expect(controller).to receive(:lock_session!).with(session_slug: 'mr_robot->my_action3')
      controller.step_to flow: :mr_robot, state: :my_action3
    end

    it "should check if an interruption occured" do
      expect(controller).to receive(:interrupt_detected?).and_return(false)
      controller.step_to flow: :mr_robot, state: :my_action3
    end

    it "should call run_interrupt_action if an interruption occured and return" do
      expect(controller).to receive(:interrupt_detected?).and_return(true)
      expect(controller).to receive(:run_interrupt_action)
      expect(controller.step_to(flow: :mr_robot, state: :my_action3)).to eq :interrupted
    end
  end

  describe "update_session_to" do
    it "should raise an ArgumentError if a session, flow, or state is not specified" do
      expect {
        controller.update_session_to
      }.to raise_error(ArgumentError)
    end

    it "should update session to flow's first state's controller action when only a flow is provided" do
      expect_any_instance_of(MrRobotsController).to_not receive(:my_action)

      controller.update_session_to flow: "mr_robot"
      expect(controller.current_session.flow_string).to eq('mr_robot')
      expect(controller.current_session.state_string).to eq('my_action')
    end

    it "should update session to controller's corresponding action when only a state is provided" do
      expect_any_instance_of(MrTronsController).to_not receive(:other_action3)

      controller.current_session.set_session(new_flow: 'mr_tron', new_state: 'other_action')

      controller.update_session_to state: "other_action3"
      expect(controller.current_session.flow_string).to eq('mr_tron')
      expect(controller.current_session.state_string).to eq('other_action3')
    end

    it "should update session to controller's corresponding action when a state and flow is provided" do
      expect_any_instance_of(MrRobotsController).to_not receive(:my_action3)

      controller.update_session_to flow: "mr_robot", state: "my_action3"
      expect(controller.current_session.flow_string).to eq('mr_robot')
      expect(controller.current_session.state_string).to eq('my_action3')
    end

    it "should update session to controller's corresponding action when a session is provided" do
      expect_any_instance_of(MrRobotsController).to_not receive(:my_action3)

      session = Stealth::Session.new(id: controller.current_session_id)
      session.set_session(new_flow: 'mr_robot', new_state: 'my_action3')

      controller.update_session_to session: session
      expect(controller.current_session.flow_string).to eq('mr_robot')
      expect(controller.current_session.state_string).to eq('my_action3')
    end

    it "should accept flow and string specified as symbols" do
      expect_any_instance_of(MrRobotsController).to_not receive(:my_action3)

      controller.update_session_to flow: :mr_robot, state: :my_action3
      expect(controller.current_session.flow_string).to eq('mr_robot')
      expect(controller.current_session.state_string).to eq('my_action3')
    end

    it "should release the lock on the session" do
      expect(controller).to receive(:release_lock!)
      controller.update_session_to flow: :mr_robot, state: :my_action3
    end

    it "should check if an interruption occured" do
      expect(controller).to receive(:interrupt_detected?).and_return(false)
      controller.update_session_to flow: :mr_robot, state: :my_action3
    end

    it "should call run_interrupt_action if an interruption occured and return" do
      expect(controller).to receive(:interrupt_detected?).and_return(true)
      expect(controller).to receive(:run_interrupt_action)
      expect(controller.update_session_to(flow: :mr_robot, state: :my_action3)).to eq :interrupted
    end
  end

  describe "step_to_in" do
    it "should raise an ArgumentError if a session, flow, or state is not specified" do
      expect {
        controller.step_to_in
      }.to raise_error(ArgumentError)
    end

    it "should raise an ArgumentError if delay is not specifed as an ActiveSupport::Duration" do
      expect {
        controller.step_to_in DateTime.now, flow: 'mr_robot'
      }.to raise_error(ArgumentError)
    end

    it "should schedule a transition to flow's first state's controller action when only a flow is provided" do
      expect_any_instance_of(MrRobotsController).to_not receive(:my_action)

      expect(Stealth::ScheduledReplyJob).to receive(:perform_in).with(
        100.seconds,
        controller.current_service,
        controller.current_session_id,
        'mr_robot',
        'my_action',
        nil
      )

      expect {
        controller.step_to_in 100.seconds, flow: "mr_robot"
      }.to_not change(controller.current_session, :get_session)
    end

    it "should schedule a transition to controller's corresponding action when only a state is provided" do
      expect_any_instance_of(MrRobotsController).to_not receive(:my_action)

      controller.current_session.set_session(new_flow: 'mr_tron', new_state: 'other_action')

      expect(Stealth::ScheduledReplyJob).to receive(:perform_in).with(
        100.seconds,
        controller.current_service,
        controller.current_session_id,
        'mr_tron',
        'other_action3',
        nil
      )

      expect {
        controller.step_to_in 100.seconds, state: "other_action3"
      }.to_not change(controller.current_session, :get_session)
    end

    it "should update session to controller's corresponding action when a state and flow is provided" do
      expect_any_instance_of(MrRobotsController).to_not receive(:my_action)

      expect(Stealth::ScheduledReplyJob).to receive(:perform_in).with(
        100.seconds,
        controller.current_service,
        controller.current_session_id,
        'mr_robot',
        'my_action3',
        nil
      )

      expect {
        controller.step_to_in 100.seconds, flow: 'mr_robot', state: "my_action3"
      }.to_not change(controller.current_session, :get_session)
    end

    it "should update session to controller's corresponding action when a session is provided" do
      expect_any_instance_of(MrRobotsController).to_not receive(:my_action)

      session = Stealth::Session.new(id: controller.current_session_id)
      session.set_session(new_flow: 'mr_robot', new_state: 'my_action3')

      expect(Stealth::ScheduledReplyJob).to receive(:perform_in).with(
        100.seconds,
        controller.current_service,
        controller.current_session_id,
        'mr_robot',
        'my_action3',
        nil
      )

      expect {
        controller.step_to_in 100.seconds, session: session
      }.to_not change(controller.current_session, :get_session)
    end

    it "should accept flow and string specified as symbols" do
      expect_any_instance_of(MrRobotsController).to_not receive(:my_action)

      expect(Stealth::ScheduledReplyJob).to receive(:perform_in).with(
        100.seconds,
        controller.current_service,
        controller.current_session_id,
        'mr_robot',
        'my_action3',
        nil
      )

      expect {
        controller.step_to_in 100.seconds, flow: :mr_robot, state: :my_action3
      }.to_not change(controller.current_session, :get_session)
    end

    it "should pass along the target_id if set on the message" do
      expect(Stealth::ScheduledReplyJob).to receive(:perform_in).with(
        100.seconds,
        controller.current_service,
        controller.current_session_id,
        'mr_robot',
        'my_action3',
        '+18885551212'
      )

      controller.current_message.target_id = '+18885551212'
      controller.step_to_in 100.seconds, flow: :mr_robot, state: :my_action3
    end

    it "should check if an interruption occured" do
      expect(controller).to receive(:interrupt_detected?).and_return(false)
      controller.step_to_in 100.seconds, flow: :mr_robot, state: :my_action3
    end

    it "should call run_interrupt_action if an interruption occured and return" do
      expect(controller).to receive(:interrupt_detected?).and_return(true)
      expect(controller).to receive(:run_interrupt_action)
      expect(controller.step_to_in(100.seconds, flow: :mr_robot, state: :my_action3)).to eq :interrupted
    end
  end

  describe "step_to_at" do
    let(:future_timestamp) { DateTime.now + 10.hours }

    it "should raise an ArgumentError if a session, flow, or state is not specified" do
      expect {
        controller.step_to_at
      }.to raise_error(ArgumentError)
    end

    it "should raise an ArgumentError if delay is not specifed as a DateTime" do
      expect {
        controller.step_to_at 100.seconds, flow: 'mr_robot'
      }.to raise_error(ArgumentError)
    end

    it "should schedule a transition to flow's first state's controller action when only a flow is provided" do
      expect_any_instance_of(MrRobotsController).to_not receive(:my_action)

      expect(Stealth::ScheduledReplyJob).to receive(:perform_at).with(
        future_timestamp,
        controller.current_service,
        controller.current_session_id,
        'mr_robot',
        'my_action',
        nil
      )

      expect {
        controller.step_to_at future_timestamp, flow: "mr_robot"
      }.to_not change(controller.current_session, :get_session)
    end

    it "should schedule a transition to controller's corresponding action when only a state is provided" do
      expect_any_instance_of(MrRobotsController).to_not receive(:my_action)

      controller.current_session.set_session(new_flow: 'mr_tron', new_state: 'other_action')

      expect(Stealth::ScheduledReplyJob).to receive(:perform_at).with(
        future_timestamp,
        controller.current_service,
        controller.current_session_id,
        'mr_tron',
        'other_action3',
        nil
      )

      expect {
        controller.step_to_at future_timestamp, state: "other_action3"
      }.to_not change(controller.current_session, :get_session)
    end

    it "should update session to controller's corresponding action when a state and flow is provided" do
      expect_any_instance_of(MrRobotsController).to_not receive(:my_action)

      expect(Stealth::ScheduledReplyJob).to receive(:perform_at).with(
        future_timestamp,
        controller.current_service,
        controller.current_session_id,
        'mr_robot',
        'my_action3',
        nil
      )

      expect {
        controller.step_to_at future_timestamp, flow: 'mr_robot', state: "my_action3"
      }.to_not change(controller.current_session, :get_session)
    end

    it "should update session to controller's corresponding action when a session is provided" do
      expect_any_instance_of(MrRobotsController).to_not receive(:my_action)

      session = Stealth::Session.new(id: controller.current_session_id)
      session.set_session(new_flow: 'mr_robot', new_state: 'my_action3')

      expect(Stealth::ScheduledReplyJob).to receive(:perform_at).with(
        future_timestamp,
        controller.current_service,
        controller.current_session_id,
        'mr_robot',
        'my_action3',
        nil
      )

      expect {
        controller.step_to_at future_timestamp, session: session
      }.to_not change(controller.current_session, :get_session)
    end

    it "should accept flow and string specified as symbols" do
      expect_any_instance_of(MrRobotsController).to_not receive(:my_action)

      expect(Stealth::ScheduledReplyJob).to receive(:perform_at).with(
        future_timestamp,
        controller.current_service,
        controller.current_session_id,
        'mr_robot',
        'my_action3',
        nil
      )

      expect {
        controller.step_to_at future_timestamp, flow: :mr_robot, state: :my_action3
      }.to_not change(controller.current_session, :get_session)
    end

    it "should pass along the target_id if set on the message" do
      expect(Stealth::ScheduledReplyJob).to receive(:perform_at).with(
        future_timestamp,
        controller.current_service,
        controller.current_session_id,
        'mr_robot',
        'my_action3',
        '+18885551212'
      )

      controller.current_message.target_id = '+18885551212'
      controller.step_to_at future_timestamp, flow: :mr_robot, state: :my_action3
    end

    it "should check if an interruption occured" do
      expect(controller).to receive(:interrupt_detected?).and_return(false)
      controller.step_to_at future_timestamp, flow: :mr_robot, state: :my_action3
    end

    it "should call run_interrupt_action if an interruption occured and return" do
      expect(controller).to receive(:interrupt_detected?).and_return(true)
      expect(controller).to receive(:run_interrupt_action)
      expect(controller.step_to_at(future_timestamp, flow: :mr_robot, state: :my_action3)).to eq :interrupted
    end
  end

  describe "set_back_to" do
    it "should set the back_to session" do
      expect {
        controller.set_back_to(flow: 'marco', state: 'polo')
      }.to change{ $redis.get([controller.current_session_id, 'back_to'].join('-')) }.to('marco->polo')
    end

    it "should default to the scoped flow if one is not specified" do
      controller.current_session.set_session(new_flow: :mr_tron, new_state: :other_action)
      expect {
        controller.set_back_to(state: 'polo')
      }.to change{ $redis.get([controller.current_session_id, 'back_to'].join('-')) }.to('mr_tron->polo')
    end

    it "should overwrite the existing back_to_session if one is already present" do
      $redis.set([controller.current_session_id, 'back_to'].join('-'), 'marco->polo')
      controller.current_session.set_session(new_flow: :mr_tron, new_state: :other_action)
      expect {
        controller.set_back_to(state: 'other_action')
      }.to change{ $redis.get([controller.current_session_id, 'back_to'].join('-')) }.from('marco->polo').to('mr_tron->other_action')
    end

    it "should check if an interruption occured" do
      expect(controller).to receive(:interrupt_detected?).and_return(false)
      controller.set_back_to flow: :mr_robot, state: :my_action3
    end

    it "should call run_interrupt_action if an interruption occured and return" do
      expect(controller).to receive(:interrupt_detected?).and_return(true)
      expect(controller).to receive(:run_interrupt_action)
      expect(controller.set_back_to(flow: :mr_robot, state: :my_action3)).to eq :interrupted
    end
  end

  describe "step_back" do
    let(:back_to_slug) { [controller.current_session_id, 'back_to'].join('-') }

    it "should raise Stealth::Errors::InvalidStateTransition if back_to_session is not set" do
      $redis.del(back_to_slug)
      expect {
        controller.step_back
      }.to raise_error(Stealth::Errors::InvalidStateTransition)
    end

    it "should step_to the stored back_to_session" do
      controller.set_back_to(flow: 'marco', state: 'polo')
      back_to_session = Stealth::Session.new(
        id: controller.current_session_id,
        type: :back_to
      )

      # We need to control the returned session object so the IDs match
      expect(Stealth::Session).to receive(:new).with(
        id: controller.current_session_id,
        type: :back_to
      ).and_return(back_to_session)
      expect(controller).to receive(:step_to).with(session: back_to_session)

      controller.step_back
    end

    it "should check if an interruption occured" do
      controller.set_back_to(flow: :mr_robot, state: :my_action3)
      expect(controller).to receive(:interrupt_detected?).and_return(false)
      controller.step_back
    end

    it "should call run_interrupt_action if an interruption occured and return" do
      controller.set_back_to(flow: :mr_robot, state: :my_action3)
      expect(controller).to receive(:interrupt_detected?).and_return(true)
      expect(controller).to receive(:run_interrupt_action)
      expect(controller.step_back).to eq :interrupted
    end
  end

  describe "progressed?" do
    it "should be truthy if an action calls step_to" do
      expect(controller.progressed?).to be_falsey
      controller.step_to flow: "mr_robot"
      expect(controller.progressed?).to be_truthy
    end

    it "should be falsey if an action only calls step_to_at" do
      expect(controller.progressed?).to be_falsey

      expect(Stealth::ScheduledReplyJob).to receive(:perform_at)
      controller.step_to_at (DateTime.now + 10.hours), flow: 'mr_robot'

      expect(controller.progressed?).to be_falsey
    end

    it "should be falsey if an action only calls step_to_in" do
      expect(controller.progressed?).to be_falsey

      expect(Stealth::ScheduledReplyJob).to receive(:perform_in)
      controller.step_to_in 100.seconds, flow: 'mr_robot'

      expect(controller.progressed?).to be_falsey
    end

    it "should be truthy if an action calls update_session_to" do
      expect(controller.progressed?).to be_falsey
      controller.update_session_to flow: "mr_robot"
      expect(controller.progressed?).to be_truthy
    end

    it "should be truthy if an action sends replies" do
      expect(controller.progressed?).to be_falsey

      # Stub out a service reply -- we just want send_replies to succeed here
      stubbed_service_reply = double("service_reply")
      allow(controller).to receive(:action_replies).and_return([], :erb)
      allow(stubbed_service_reply).to receive(:replies).and_return([])
      allow(Stealth::ServiceReply).to receive(:new).and_return(stubbed_service_reply)

      controller.send_replies
      expect(controller.progressed?).to be_truthy
    end

    it "should be falsey otherwise" do
      allow(controller).to receive(:flow_controller).and_return(controller)
      expect(controller.progressed?).to be_falsey
      controller.action(action: :other_action)
      expect(controller.progressed?).to be_falsey
    end
  end

  describe "do_nothing" do
    it "should set progressed to truthy when called" do
      allow(controller).to receive(:flow_controller).and_return(controller)
      expect(controller.progressed?).to be_falsey
      controller.action(action: :other_action4)
      expect(controller.progressed?).to be_truthy
    end

    it "should release the lock on the session" do
      expect(controller).to receive(:release_lock!)
      controller.do_nothing
    end
  end

  describe "update_session" do
    before(:each) do
      controller.current_session.set_session(new_flow: 'mr_tron', new_state: 'other_action')
    end

    it "should set progressed to :updated_session" do
      controller.send(:update_session, flow: :mr_tron, state: :other_action)
      expect(controller.progressed?).to eq :updated_session
    end

    it "call set_session on the current_session with the new flow and state" do
      controller.send(:update_session, flow: :mr_robot, state: :my_action)
      expect(controller.current_session.flow_string).to eq 'mr_robot'
      expect(controller.current_session.state_string).to eq 'my_action'
    end

    it "should not call set_session on current_session if the flow and state match" do
      expect_any_instance_of(Stealth::Session).to_not receive(:set_session)
      controller.send(:update_session, flow: :mr_tron, state: :other_action)
    end
  end

  describe "dev jumps" do
    let!(:dev_env) { ActiveSupport::StringInquirer.new('development') }

    describe "dev_jump_detected?" do
      it "should return false if the enviornment is not 'development'" do
        expect(Stealth.env).to eq 'test'
        expect(controller.send(:dev_jump_detected?)).to be false
      end

      it "should return false if the message does not match the jump format" do
        allow(Stealth).to receive(:env).and_return(dev_env)
        controller.current_message.message = 'hello world'
        expect(Stealth.env.development?).to be true
        expect(controller.send(:dev_jump_detected?)).to be false
      end

      describe "with a dev jump message" do
        before(:each) do
          expect(controller).to receive(:handle_dev_jump).and_return(true)
          expect(Stealth).to receive(:env).and_return(dev_env)
        end

        it "should return true if the message is in the format /flow/state" do
          controller.current_message.message = '/mr_robot/my_action'
          expect(controller.send(:dev_jump_detected?)).to be true
        end

        it "should return true if the message is in the format /flow" do
          controller.current_message.message = '/mr_robot'
          expect(controller.send(:dev_jump_detected?)).to be true
        end

        it "should return true if the message is in the format //state" do
          controller.current_message.message = '//my_action'
          expect(controller.send(:dev_jump_detected?)).to be true
        end
      end
    end

    describe "handle_dev_jump" do
      it "should handle messages in the format /flow/state" do
        controller.current_message.message = '/mr_robot/my_action'
        expect(controller).to receive(:step_to).with(flow: 'mr_robot', state: 'my_action')
        controller.send(:handle_dev_jump)
      end

      it "should handle messages in the format /flow" do
        controller.current_message.message = '/mr_robot'
        expect(controller).to receive(:step_to).with(flow: 'mr_robot', state: nil)
        controller.send(:handle_dev_jump)
      end

      it "should handle messages in the format //state" do
        controller.current_message.message = '//my_action'
        expect(controller).to receive(:step_to).with(flow: nil, state: 'my_action')
        controller.send(:handle_dev_jump)
      end
    end
  end

end
