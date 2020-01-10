# frozen_string_literal: true

require 'spec_helper'

describe "Stealth::Controller::DynamicDelay" do

  let(:facebook_message) { SampleMessage.new(service: 'facebook') }
  let(:controller) { VadersController.new(service_message: facebook_message.message_with_text) }
  let(:service_replies) { YAML.load(File.read(File.expand_path("../replies/messages/say_howdy_with_dynamic.yml", __dir__))) }

  it "should return a SHORT_DELAY for a dynamic delay at position 0" do
    delay = controller.dynamic_delay(service_replies: service_replies, position: 0)
    expect(delay).to eq(Stealth::Controller::DynamicDelay::SHORT_DELAY)
  end

  it "should return a SHORT_DELAY for a dynamic delay at position -1" do
    delay = controller.dynamic_delay(service_replies: service_replies, position: -1)
    expect(delay).to eq(Stealth::Controller::DynamicDelay::SHORT_DELAY)
  end

  it "should return a SHORT_DELAY for text 35 chars long" do
    delay = controller.dynamic_delay(service_replies: service_replies, position: 2)
    expect(delay).to eq(Stealth::Controller::DynamicDelay::SHORT_DELAY)
  end

  it "should return a STANDARD_DELAY for text 120 chars long" do
    delay = controller.dynamic_delay(service_replies: service_replies, position: 4)
    expect(delay).to eq(Stealth::Controller::DynamicDelay::STANDARD_DELAY)
  end

  it "should return a (STANDARD_DELAY * 1.5) for text 230 chars long" do
    delay = controller.dynamic_delay(service_replies: service_replies, position: 6)
    expect(delay).to eq(Stealth::Controller::DynamicDelay::STANDARD_DELAY * 1.5)
  end

  it "should return a LONG_DELAY for text 350 chars long" do
    delay = controller.dynamic_delay(service_replies: service_replies, position: 8)
    expect(delay).to eq(Stealth::Controller::DynamicDelay::LONG_DELAY)
  end

  it "should return a STANDARD_DELAY for an image" do
    delay = controller.dynamic_delay(service_replies: service_replies, position: 10)
    expect(delay).to eq(Stealth::Controller::DynamicDelay::STANDARD_DELAY)
  end

  it "should return a STANDARD_DELAY for a video" do
    delay = controller.dynamic_delay(service_replies: service_replies, position: 12)
    expect(delay).to eq(Stealth::Controller::DynamicDelay::STANDARD_DELAY)
  end

  it "should return a STANDARD_DELAY for an audio" do
    delay = controller.dynamic_delay(service_replies: service_replies, position: 14)
    expect(delay).to eq(Stealth::Controller::DynamicDelay::STANDARD_DELAY)
  end

  it "should return a STANDARD_DELAY for a file" do
    delay = controller.dynamic_delay(service_replies: service_replies, position: 16)
    expect(delay).to eq(Stealth::Controller::DynamicDelay::STANDARD_DELAY)
  end

  it "should return a STANDARD_DELAY for cards" do
    delay = controller.dynamic_delay(service_replies: service_replies, position: 18)
    expect(delay).to eq(Stealth::Controller::DynamicDelay::STANDARD_DELAY)
  end

  it "should return a STANDARD_DELAY for a list" do
    delay = controller.dynamic_delay(service_replies: service_replies, position: 20)
    expect(delay).to eq(Stealth::Controller::DynamicDelay::STANDARD_DELAY)
  end
end
