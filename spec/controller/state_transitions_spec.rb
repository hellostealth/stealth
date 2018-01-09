# frozen_string_literal: true

require File.expand_path(File.join(File.dirname(__FILE__), '..', '/spec_helper'))

describe "Stealth::Controller state transitions" do

  class MrRobotsController < BotController
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

  class MrTronsController < BotController
    def other_action

    end

    def other_action2

    end

    def other_action3

    end
  end

  class MrRobotFlow
    include Stealth::Flow

    flow do
      state :my_action
      state :my_action2
      state :my_action3
    end
  end

  class MrTronFlow
    include Stealth::Flow

    flow do
      state :other_action
      state :other_action2
      state :other_action3
    end
  end

  let(:facebook_message) { SampleMessage.new(service: 'facebook') }

  describe "step_to" do
    it "should raise an ArgumentError if a session, flow, or state is not specified" do
      controller = MrTronsController.new(service_message: facebook_message.message_with_text)
      expect {
        controller.step_to
      }.to raise_error(ArgumentError)
    end

    it "should call the flow's first state's controller action when only a flow is provided" do

    end

    it "should call a controller's corresponding action when only a state is provided" do

    end

    it "should call a controller's corresponding action when a state and flow is provided" do

    end

    it "should call a controller's corresponding action when a session is provided" do

    end
  end

  describe "update_session_to" do
    it "should raise an ArgumentError if a session, flow, or state is not specified" do
      controller = MrTronsController.new(service_message: facebook_message.message_with_text)
      expect {
        controller.update_session_to
      }.to raise_error(ArgumentError)
    end
  end

  describe "step_to_in" do
    it "should raise an ArgumentError if a session, flow, or state is not specified" do
      controller = MrTronsController.new(service_message: facebook_message.message_with_text)
      expect {
        controller.step_to_in
      }.to raise_error(ArgumentError)
    end
  end

  describe "step_to_next" do

  end

  describe "update_session_to_next" do

  end

end
