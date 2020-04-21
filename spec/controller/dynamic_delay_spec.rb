# frozen_string_literal: true

require 'spec_helper'

describe "Stealth::Controller::DynamicDelay" do

  let(:facebook_message) { SampleMessage.new(service: 'facebook') }
  let(:controller) { VadersController.new(service_message: facebook_message.message_with_text) }
  let!(:service_replies) { YAML.load(File.read(File.expand_path("../replies/messages/say_howdy_with_dynamic.yml", __dir__))) }

  it "should return a SHORT_DELAY for a dynamic delay at position 0" do
    delay = controller.dynamic_delay(previous_reply: nil)
    expect(delay).to eq(Stealth::Controller::DynamicDelay::SHORT_DELAY)
  end

  it "should return a STANDARD_DELAY for a dynamic delay at position -2" do
    delay = controller.dynamic_delay(previous_reply: service_replies[-2])
    expect(delay).to eq(Stealth::Controller::DynamicDelay::STANDARD_DELAY)
  end

  it "should return a SHORT_DELAY for text 35 chars long" do
    delay = controller.dynamic_delay(previous_reply: service_replies[1])
    expect(delay).to eq(Stealth::Controller::DynamicDelay::SHORT_DELAY)
  end

  it "should return a STANDARD_DELAY for text 120 chars long" do
    delay = controller.dynamic_delay(previous_reply: service_replies[3])
    expect(delay).to eq(Stealth::Controller::DynamicDelay::STANDARD_DELAY)
  end

  it "should return a (STANDARD_DELAY * 1.5) for text 230 chars long" do
    delay = controller.dynamic_delay(previous_reply: service_replies[5])
    expect(delay).to eq(Stealth::Controller::DynamicDelay::STANDARD_DELAY * 1.5)
  end

  it "should return a LONG_DELAY for text 350 chars long" do
    delay = controller.dynamic_delay(previous_reply: service_replies[7])
    expect(delay).to eq(Stealth::Controller::DynamicDelay::LONG_DELAY)
  end

  it "should return a STANDARD_DELAY for an image" do
    delay = controller.dynamic_delay(previous_reply: service_replies[9])
    expect(delay).to eq(Stealth::Controller::DynamicDelay::STANDARD_DELAY)
  end

  it "should return a STANDARD_DELAY for a video" do
    delay = controller.dynamic_delay(previous_reply: service_replies[11])
    expect(delay).to eq(Stealth::Controller::DynamicDelay::STANDARD_DELAY)
  end

  it "should return a STANDARD_DELAY for an audio" do
    delay = controller.dynamic_delay(previous_reply: service_replies[13])
    expect(delay).to eq(Stealth::Controller::DynamicDelay::STANDARD_DELAY)
  end

  it "should return a STANDARD_DELAY for a file" do
    delay = controller.dynamic_delay(previous_reply: service_replies[15])
    expect(delay).to eq(Stealth::Controller::DynamicDelay::STANDARD_DELAY)
  end

  it "should return a STANDARD_DELAY for cards" do
    delay = controller.dynamic_delay(previous_reply: service_replies[17])
    expect(delay).to eq(Stealth::Controller::DynamicDelay::STANDARD_DELAY)
  end

  it "should return a STANDARD_DELAY for a list" do
    delay = controller.dynamic_delay(previous_reply: service_replies[19])
    expect(delay).to eq(Stealth::Controller::DynamicDelay::STANDARD_DELAY)
  end
end
