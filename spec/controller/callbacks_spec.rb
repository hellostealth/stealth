# coding: utf-8
# frozen_string_literal: true

require File.expand_path(File.join(File.dirname(__FILE__), '..', '/spec_helper'))

$history = []

class BotController < Stealth::Controller
  before_action :fetch_user_name

  def some_action
    step_to flow: 'flow_tester', state: 'my_action'
  end

  def other_action
    step_to flow: 'other_flow_tester', state: 'other_action'
  end

  def halted_action
    step_to flow: 'flow_tester', state: 'my_action2'
  end

  def filtered_action
    step_to flow: 'flow_tester', state: 'my_action3'
  end

  def some_other_action2
    step_to flow: 'other_flow_tester', state: 'other_action2'
  end

  def some_other_action3
    step_to flow: 'other_flow_tester', state: 'other_action3'
  end

  def some_other_action4
    step_to flow: 'other_flow_tester', state: 'other_action4'
  end

  def some_other_action5
    step_to flow: 'other_flow_tester', state: 'other_action5'
  end

  private

    def fetch_user_name
      $history << "fetched user name"
    end
end

class FlowTestersController < BotController
  before_action :test_before_halting, only: :my_action2
  before_action :test_action
  before_action :test_filtering, except: [:my_action, :my_action2]

  attr_reader :action_ran

  def my_action

  end

  def my_action2

  end

  def my_action3

  end

  protected

    def test_action
      $history << "tested action"
    end

    def test_before_halting
      throw(:abort)
    end

    def test_filtering
      $history << "filtered"
    end

    def test_after_halting
      $history << "after action ran"
    end
end

class OtherFlowTestersController < BotController
  after_action :after_action1, only: :other_action2
  after_action :after_action2, only: :other_action2

  before_action :run_halt, only: [:other_action3, :other_action5]
  after_action :after_action3, only: :other_action3

  around_action :run_around_filter, only: [:other_action4, :other_action5]

  def other_action

  end

  def other_action2

  end

  def other_action3

  end

  def other_action4

  end

  def other_action5

  end

  private

    def after_action1
      $history << "after action 1"
    end

    def after_action2
      $history << "after action 2"
    end

    def run_halt
      throw(:abort)
    end

    def run_around_filter
      $history << "around before"
      yield
      $history << "around after"
    end
end

class FlowMap
  include Stealth::Flow

  flow :flow_tester do
    state :my_action
    state :my_action2
    state :my_action3
  end

  flow :other_flow_tester do
    state :other_action
    state :other_action2
    state :other_action3
    state :other_action4
    state :other_action5
  end
end

describe "Stealth::Controller callbacks" do

  let(:facebook_message) { SampleMessage.new(service: 'facebook') }

  before(:each) do
    $history = []
  end

  describe "before_action" do
    it "should fire the callback on the parent class" do
      controller = BotController.new(service_message: facebook_message.message_with_text)
      controller.other_action
      expect($history).to eq ["fetched user name"]
    end

    it "should fire the callback on a child class" do
      controller = FlowTestersController.new(service_message: facebook_message.message_with_text)
      controller.some_action
      expect($history).to eq ["fetched user name", "tested action"]
    end

    it "should halt the callback chain when :abort is thrown" do
      controller = FlowTestersController.new(service_message: facebook_message.message_with_text)
      controller.halted_action
      expect($history).to eq ["fetched user name"]
    end

    it "should respect 'unless' filter" do
      controller = FlowTestersController.new(service_message: facebook_message.message_with_text)
      controller.filtered_action
      expect($history).to eq ["fetched user name", "tested action", "filtered"]
    end
  end

  describe "after_action" do
    it "should fire the after callbacks in reverse order" do
      controller = OtherFlowTestersController.new(service_message: facebook_message.message_with_text)
      controller.some_other_action2
      expect($history).to eq ["fetched user name", "after action 2", "after action 1"]
    end

    it "should not fire after callbacks if a before callback throws an :abort" do
      controller = OtherFlowTestersController.new(service_message: facebook_message.message_with_text)
      controller.some_other_action3
      expect($history).to eq ["fetched user name"]
    end
  end

  describe "around_action" do
    it "should fire the around callback before and after" do
      controller = OtherFlowTestersController.new(service_message: facebook_message.message_with_text)
      controller.some_other_action4
      expect($history).to eq ["fetched user name", "around before", "around after"]
    end

    it "should not fire the around callback if a before callback throws abort" do
      controller = OtherFlowTestersController.new(service_message: facebook_message.message_with_text)
      controller.some_other_action5
      expect($history).to eq ["fetched user name"]
    end
  end

end
