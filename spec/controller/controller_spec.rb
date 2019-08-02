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
  let(:controller) { MrTronsController.new(service_message: facebook_message.message_with_text) }

  describe "convenience methods" do
    it "should make the session ID accessible via current_session_id" do
      controller.current_session.set(flow: 'mr_tron', state: 'other_action', params: {})

      expect(controller.current_session_id).to eq(facebook_message.sender_id)
    end

    it "should make the session ID accessible via current_user_id" do
      controller.current_session.set(flow: 'mr_tron', state: 'other_action', params: {})

      expect(controller.current_user_id).to eq(facebook_message.sender_id)
    end

    it "should make params available in current_session.params" do
      controller.current_session.set(flow: 'mr_tron', state: 'other_action', params: { 'key' => 'value' })

      expect(controller.current_session.params).to eq({ 'key' => 'value' })
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
      controller.current_session.session = Stealth::Session.canonical_session_slug(flow: 'mr_tron', state: 'deprecated_action', params: {})
      expect(MrTronsController).to receive(:new).and_return(controller)
      expect(controller).to receive(:other_action)
      controller.action(action: :deprecated_action)
    end

    it "should step_to the specified redirect flow and state when a session is specified" do
      controller.current_session.session = Stealth::Session.canonical_session_slug(flow: 'mr_tron', state: 'deprecated_action2', params: {})
      mr_robot_controller = MrTronsController.new(service_message: facebook_message.message_with_text)

      expect(MrRobotsController).to receive(:new).and_return(mr_robot_controller)
      expect(mr_robot_controller).to receive(:my_action)
      controller.action(action: :deprecated_action2)
    end

    it "should NOT call the redirected controller action method" do
      controller.current_session.session = Stealth::Session.canonical_session_slug(flow: 'mr_tron', state: 'deprecated_action', params: {})
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

      controller.current_session.set(flow: 'mr_tron', state: 'other_action', params: {})

      controller.step_to state: "other_action3"
    end

    it "should call a controller's corresponding action with params set on current_session when a state, flow and params is provided" do
      expect_any_instance_of(MrRobotsController).to receive(:my_action3)
      controller.step_to flow: "mr_robot", state: "my_action3", params: { 'key' => 'value' }
      
      expect(controller.current_session.params).to eq({ 'key' => 'value' })
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

      controller.current_session.set(flow: 'mr_tron', state: 'other_action', params: {})

      controller.update_session_to state: "other_action3"
      expect(controller.current_session.flow_string).to eq('mr_tron')
      expect(controller.current_session.state_string).to eq('other_action3')
    end

    it "should update session to controller's corresponding action when a state, flow and params is provided" do
      expect_any_instance_of(MrRobotsController).to_not receive(:my_action3)

      controller.update_session_to flow: "mr_robot", state: "my_action3", params: { 'key' => 'value' }
      expect(controller.current_session.flow_string).to eq('mr_robot')
      expect(controller.current_session.state_string).to eq('my_action3')
      expect(controller.current_session.params).to eq({ 'key' => 'value' })
    end

    it "should update session to controller's corresponding action when a session is provided" do
      expect_any_instance_of(MrRobotsController).to_not receive(:my_action3)

      session = Stealth::Session.new(user_id: controller.current_session_id)
      session.set(flow: 'mr_robot', state: 'my_action3', params: { 'key' => 'value' })

      controller.update_session_to session: session
      expect(controller.current_session.flow_string).to eq('mr_robot')
      expect(controller.current_session.state_string).to eq('my_action3')
      expect(controller.current_session.params).to eq({ 'key' => 'value' })
    end

    it "should accept flow and string specified as symbols" do
      expect_any_instance_of(MrRobotsController).to_not receive(:my_action3)

      controller.update_session_to flow: :mr_robot, state: :my_action3
      expect(controller.current_session.flow_string).to eq('mr_robot')
      expect(controller.current_session.state_string).to eq('my_action3')
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
        {}
      )

      expect {
        controller.step_to_in 100.seconds, flow: "mr_robot"
      }.to_not change(controller.current_session, :get)
    end

    it "should schedule a transition to controller's corresponding action when only a state is provided" do
      expect_any_instance_of(MrRobotsController).to_not receive(:my_action)

      controller.current_session.set(flow: 'mr_tron', state: 'other_action', params: {})

      expect(Stealth::ScheduledReplyJob).to receive(:perform_in).with(
        100.seconds,
        controller.current_service,
        controller.current_session_id,
        'mr_tron',
        'other_action3',
        {}
      )

      expect {
        controller.step_to_in 100.seconds, state: "other_action3"
      }.to_not change(controller.current_session, :get)
    end

    it "should update session to controller's corresponding action when a state, flow and params is provided" do
      expect_any_instance_of(MrRobotsController).to_not receive(:my_action)

      expect(Stealth::ScheduledReplyJob).to receive(:perform_in).with(
        100.seconds,
        controller.current_service,
        controller.current_session_id,
        'mr_robot',
        'my_action3',
        { 'key' => 'value' }
      )

      expect {
        controller.step_to_in 100.seconds, flow: 'mr_robot', state: "my_action3", params: { 'key' => 'value' }
      }.to_not change(controller.current_session, :get)
    end

    it "should update session to controller's corresponding action when a session is provided" do
      expect_any_instance_of(MrRobotsController).to_not receive(:my_action)

      session = Stealth::Session.new(user_id: controller.current_session_id)
      session.set(flow: 'mr_robot', state: 'my_action3', params: { 'key' => 'value' })

      expect(Stealth::ScheduledReplyJob).to receive(:perform_in).with(
        100.seconds,
        controller.current_service,
        controller.current_session_id,
        'mr_robot',
        'my_action3',
        { 'key' => 'value' }
      )

      expect {
        controller.step_to_in 100.seconds, session: session
      }.to_not change(controller.current_session, :get)
    end

    it "should accept flow and string specified as symbols" do
      expect_any_instance_of(MrRobotsController).to_not receive(:my_action)

      expect(Stealth::ScheduledReplyJob).to receive(:perform_in).with(
        100.seconds,
        controller.current_service,
        controller.current_session_id,
        'mr_robot',
        'my_action3',
        {}
      )

      expect {
        controller.step_to_in 100.seconds, flow: :mr_robot, state: :my_action3
      }.to_not change(controller.current_session, :get)
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
        {}
      )

      expect {
        controller.step_to_at future_timestamp, flow: "mr_robot"
      }.to_not change(controller.current_session, :get)
    end

    it "should schedule a transition to controller's corresponding action when only a state is provided" do
      expect_any_instance_of(MrRobotsController).to_not receive(:my_action)

      controller.current_session.set(flow: 'mr_tron', state: 'other_action', params: {})

      expect(Stealth::ScheduledReplyJob).to receive(:perform_at).with(
        future_timestamp,
        controller.current_service,
        controller.current_session_id,
        'mr_tron',
        'other_action3',
        {}
      )

      expect {
        controller.step_to_at future_timestamp, state: "other_action3"
      }.to_not change(controller.current_session, :get)
    end

    it "should update session to controller's corresponding action when a state, flow and params is provided" do
      expect_any_instance_of(MrRobotsController).to_not receive(:my_action)

      expect(Stealth::ScheduledReplyJob).to receive(:perform_at).with(
        future_timestamp,
        controller.current_service,
        controller.current_session_id,
        'mr_robot',
        'my_action3',
        { 'key' => 'value' }
      )

      expect {
        controller.step_to_at future_timestamp, flow: 'mr_robot', state: "my_action3", params: { 'key' => 'value' }
      }.to_not change(controller.current_session, :get)
    end

    it "should update session to controller's corresponding action when a session is provided" do
      expect_any_instance_of(MrRobotsController).to_not receive(:my_action)

      session = Stealth::Session.new(user_id: controller.current_session_id)
      session.set(flow: 'mr_robot', state: 'my_action3', params: { 'key' => 'value' })

      expect(Stealth::ScheduledReplyJob).to receive(:perform_at).with(
        future_timestamp,
        controller.current_service,
        controller.current_session_id,
        'mr_robot',
        'my_action3',
        { 'key' => 'value' }
      )

      expect {
        controller.step_to_at future_timestamp, session: session
      }.to_not change(controller.current_session, :get)
    end

    it "should accept flow and string specified as symbols" do
      expect_any_instance_of(MrRobotsController).to_not receive(:my_action)

      expect(Stealth::ScheduledReplyJob).to receive(:perform_at).with(
        future_timestamp,
        controller.current_service,
        controller.current_session_id,
        'mr_robot',
        'my_action3',
        {}
      )

      expect {
        controller.step_to_at future_timestamp, flow: :mr_robot, state: :my_action3
      }.to_not change(controller.current_session, :get)
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
  end

end
