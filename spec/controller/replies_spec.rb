# frozen_string_literal: true

require 'spec_helper'

describe "Stealth::Controller replies" do

  Stealth::Controller._replies_path = File.expand_path("../replies", __dir__)

  let(:facebook_message) { SampleMessage.new(service: 'facebook') }
  let(:controller) { MessagesController.new(service_message: facebook_message.message_with_text) }

  # Stub out base Facebook integration
  module Stealth
    module Services
      module Facebook
        class ReplyHandler

        end

        class Client

        end
      end
    end
  end

  class MessagesController < Stealth::Controller
    def say_oi
      @first_name = "Presley"
      send_replies
    end

    def say_offer
      send_replies
    end

    def say_offer_with_dynamic
      send_replies
    end

    def say_uh_oh
      send_replies
    end

    def say_randomize_text
      send_replies
    end

    def say_randomize_speech
      send_replies
    end

    def say_custom_reply
      send_replies custom_reply: 'messages/say_offer'
    end

    def say_nested_custom_reply
      send_replies custom_reply: 'messages/sub1/sub2/say_nested'
    end

    def say_inline_reply
      reply = [
        { 'reply_type' => 'text', 'text' => 'Hi, Morty. Welcome to Stealth bot...' },
        { 'reply_type' => 'delay', 'duration' => 2 },
        { 'reply_type' => 'text', 'text' => 'We offer users an awesome Ruby framework for building chat bots.' }
      ]

      send_replies inline: reply
    end
  end

  describe "missing reply" do
    it "should raise a Stealth::Errors::ReplyNotFound" do
      allow(controller.current_session).to receive(:flow_string).and_return("message")
      allow(controller.current_session).to receive(:state_string).and_return("say_uh_oh")

      expect {
        controller.send_replies
      }.to raise_error(Stealth::Errors::ReplyNotFound)
    end
  end

  describe "class attributes" do
    it "should have altered the _replies_path class attribute" do
      expect(MessagesController._replies_path).to eq(File.expand_path("../replies", __dir__))
    end

    it "should have altered the _preprocessors class attribute" do
      expect(MessagesController._preprocessors).to eq([:erb])
    end
  end

  describe "action_replies" do
    it "should select the :erb preprocessor when reply extension is .yml" do
      allow(controller.current_session).to receive(:flow_string).and_return("message")
      allow(controller.current_session).to receive(:state_string).and_return("say_oi")
      file_contents, selected_preprocessor = controller.send(:action_replies)

      expect(selected_preprocessor).to eq(:erb)
    end

    it "should select the :none preprocessor when there is no reply extension" do
      allow(controller.current_session).to receive(:flow_string).and_return("message")
      allow(controller.current_session).to receive(:state_string).and_return("say_offer")
      file_contents, selected_preprocessor = controller.send(:action_replies)

      expect(selected_preprocessor).to eq(:none)
    end

    it "should read the reply's file contents" do
      allow(controller.current_session).to receive(:flow_string).and_return("message")
      allow(controller.current_session).to receive(:state_string).and_return("say_offer")
      file_contents, selected_preprocessor = controller.send(:action_replies)

      expect(file_contents).to eq(File.read(File.expand_path("../replies/messages/say_offer.yml", __dir__)))
    end
  end

  describe "reply with ERB" do
    let(:stubbed_handler) { double("handler") }
    let(:stubbed_client) { double("client") }

    before(:each) do
      allow(Stealth::Services::Facebook::ReplyHandler).to receive(:new).and_return(stubbed_handler)
      allow(Stealth::Services::Facebook::Client).to receive(:new).and_return(stubbed_client)
      allow(controller.current_session).to receive(:flow_string).and_return("message")
      allow(controller.current_session).to receive(:state_string).and_return("say_oi")
    end

    it "should translate each reply_type in the reply" do
      allow(stubbed_client).to receive(:transmit).and_return(true)
      allow(controller).to receive(:sleep).and_return(true)

      expect(stubbed_handler).to receive(:text).exactly(3).times
      expect(stubbed_handler).to receive(:delay).exactly(2).times
      controller.say_oi
    end

    it "should transmit each reply_type in the reply" do
      allow(stubbed_handler).to receive(:text).exactly(3).times
      allow(stubbed_handler).to receive(:delay).exactly(2).times
      allow(controller).to receive(:sleep).and_return(true)

      expect(stubbed_client).to receive(:transmit).exactly(5).times
      controller.say_oi
    end

    it "should sleep on delays" do
      allow(stubbed_handler).to receive(:text).exactly(3).times
      allow(stubbed_handler).to receive(:delay).exactly(2).times
      allow(stubbed_client).to receive(:transmit).exactly(5).times

      expect(controller).to receive(:sleep).exactly(2).times
      controller.say_oi
    end
  end

  describe "plain reply" do
    let(:stubbed_handler) { double("handler") }
    let(:stubbed_client) { double("client") }

    before(:each) do
      allow(Stealth::Services::Facebook::ReplyHandler).to receive(:new).and_return(stubbed_handler)
      allow(Stealth::Services::Facebook::Client).to receive(:new).and_return(stubbed_client)
      allow(controller.current_session).to receive(:flow_string).and_return("message")
      allow(controller.current_session).to receive(:state_string).and_return("say_offer")
    end

    it "should translate each reply_type in the reply" do
      allow(stubbed_client).to receive(:transmit).and_return(true)
      allow(controller).to receive(:sleep).and_return(true).with(2.0)

      expect(stubbed_handler).to receive(:text).exactly(2).times
      expect(stubbed_handler).to receive(:delay).exactly(1).times
      controller.say_offer
    end

    it "should transmit each reply_type in the reply" do
      allow(stubbed_handler).to receive(:text).exactly(2).times
      allow(stubbed_handler).to receive(:delay).exactly(1).times
      allow(controller).to receive(:sleep).and_return(true).with(2.0)

      expect(stubbed_client).to receive(:transmit).exactly(3).times
      controller.say_offer
    end

    it "should sleep on delays" do
      allow(stubbed_handler).to receive(:text).exactly(2).times
      allow(stubbed_handler).to receive(:delay).exactly(1).times
      allow(stubbed_client).to receive(:transmit).exactly(3).times

      expect(controller).to receive(:sleep).exactly(1).times.with(2.0)
      controller.say_offer
    end
  end

  describe "custom_reply" do
    let(:stubbed_handler) { double("handler") }
    let(:stubbed_client) { double("client") }

    before(:each) do
      allow(Stealth::Services::Facebook::ReplyHandler).to receive(:new).and_return(stubbed_handler)
      allow(Stealth::Services::Facebook::Client).to receive(:new).and_return(stubbed_client)
      allow(controller.current_session).to receive(:flow_string).and_return("message")
      allow(controller.current_session).to receive(:state_string).and_return("say_custom_reply")
    end

    it "should translate each reply_type in the reply" do
      allow(stubbed_client).to receive(:transmit).and_return(true)
      allow(controller).to receive(:sleep).and_return(true).with(2.0)

      expect(stubbed_handler).to receive(:text).exactly(2).times
      expect(stubbed_handler).to receive(:delay).exactly(1).times
      controller.say_custom_reply
    end

    it "should transmit each reply_type in the reply" do
      allow(stubbed_handler).to receive(:text).exactly(2).times
      allow(stubbed_handler).to receive(:delay).exactly(1).times
      allow(controller).to receive(:sleep).and_return(true).with(2.0)

      expect(stubbed_client).to receive(:transmit).exactly(3).times
      controller.say_custom_reply
    end

    it "should sleep on delays" do
      allow(stubbed_handler).to receive(:text).exactly(2).times
      allow(stubbed_handler).to receive(:delay).exactly(1).times
      allow(stubbed_client).to receive(:transmit).exactly(3).times

      expect(controller).to receive(:sleep).exactly(1).times.with(2.0)
      controller.say_custom_reply
    end

    it "should correctly load from sub-dirs" do
      expect(stubbed_handler).to receive(:text).exactly(3).times
      expect(stubbed_handler).to receive(:delay).exactly(2).times
      expect(stubbed_client).to receive(:transmit).exactly(5).times

      expect(controller).to receive(:sleep).exactly(2).times.with(2.0)
      controller.say_nested_custom_reply
    end
  end

  describe "inline replies" do
    let(:stubbed_handler) { double("handler") }
    let(:stubbed_client) { double("client") }

    before(:each) do
      allow(Stealth::Services::Facebook::ReplyHandler).to receive(:new).and_return(stubbed_handler)
      allow(Stealth::Services::Facebook::Client).to receive(:new).and_return(stubbed_client)
      allow(controller.current_session).to receive(:flow_string).and_return("message")
      allow(controller.current_session).to receive(:state_string).and_return("say_inline_reply")
    end

    it "should translate each reply_type in the reply" do
      allow(stubbed_client).to receive(:transmit).and_return(true)
      allow(controller).to receive(:sleep).and_return(true).with(2.0)

      expect(stubbed_handler).to receive(:text).exactly(2).times
      expect(stubbed_handler).to receive(:delay).exactly(1).times
      controller.say_inline_reply
    end

    it "should transmit each reply_type in the reply" do
      allow(stubbed_handler).to receive(:text).exactly(2).times
      allow(stubbed_handler).to receive(:delay).exactly(1).times
      allow(controller).to receive(:sleep).and_return(true).with(2.0)

      expect(stubbed_client).to receive(:transmit).exactly(3).times
      controller.say_inline_reply
    end

    it "should sleep on delays" do
      allow(stubbed_handler).to receive(:text).exactly(2).times
      allow(stubbed_handler).to receive(:delay).exactly(1).times
      allow(stubbed_client).to receive(:transmit).exactly(3).times

      expect(controller).to receive(:sleep).exactly(1).times.with(2.0)
      controller.say_inline_reply
    end
  end

  describe "session locking" do
    let(:stubbed_handler) { double("handler") }
    let(:stubbed_client) { double("client") }

    before(:each) do
      allow(Stealth::Services::Facebook::ReplyHandler).to receive(:new).and_return(stubbed_handler)
      allow(Stealth::Services::Facebook::Client).to receive(:new).and_return(stubbed_client)
      allow(controller.current_session).to receive(:flow_string).and_return("message")
      allow(controller.current_session).to receive(:state_string).and_return("say_offer")
    end

    it "should update the lock for each reply_type in the reply" do
      allow(stubbed_client).to receive(:transmit).and_return(true)
      allow(controller).to receive(:sleep).and_return(true).with(2.0)

      expect(controller).to receive(:lock_session!).exactly(3).times
      expect(stubbed_handler).to receive(:text).exactly(2).times
      expect(stubbed_handler).to receive(:delay).exactly(1).times
      controller.say_offer
    end

    it "should update the lock position for each reply_type in the reply" do
      allow(stubbed_client).to receive(:transmit).and_return(true)
      allow(controller).to receive(:sleep).and_return(true).with(2.0)

      expect(controller).to receive(
        :lock_session!
      ).with(
        session_slug: controller.current_session.get_session,
        position: 0
      ).exactly(1).times

      expect(controller).to receive(
        :lock_session!
      ).with(
        session_slug: controller.current_session.get_session,
        position: 1
      ).exactly(1).times

      expect(controller).to receive(
        :lock_session!
      ).with(
        session_slug: controller.current_session.get_session,
        position: 2
      ).exactly(1).times

      expect(stubbed_handler).to receive(:text).exactly(2).times
      expect(stubbed_handler).to receive(:delay).exactly(1).times
      controller.say_offer
    end
  end

  describe "dynamic delays" do
    let(:stubbed_handler) { double("handler") }
    let(:stubbed_client) { double("client") }

    before(:each) do
      allow(Stealth::Services::Facebook::ReplyHandler).to receive(:new).and_return(stubbed_handler)
      allow(Stealth::Services::Facebook::Client).to receive(:new).and_return(stubbed_client)
      allow(controller.current_session).to receive(:flow_string).and_return("message")
      allow(controller.current_session).to receive(:state_string).and_return("say_offer_with_dynamic")
    end

    it "should use the default multiplier if none is set" do
      allow(stubbed_handler).to receive(:text).exactly(2).times
      allow(stubbed_handler).to receive(:delay).exactly(1).times
      allow(stubbed_client).to receive(:transmit).exactly(3).times

      delay = Stealth.config.dynamic_delay_muliplier * Stealth::Controller::DynamicDelay::SHORT_DELAY
      expect(controller).to receive(:sleep).exactly(1).times.with(delay)
      controller.say_offer_with_dynamic
    end

    it "should slow down SHORT_DELAY if dynamic_delay_muliplier > 1" do
      allow(stubbed_handler).to receive(:text).exactly(2).times
      allow(stubbed_handler).to receive(:delay).exactly(1).times
      allow(stubbed_client).to receive(:transmit).exactly(3).times

      Stealth.config.dynamic_delay_muliplier = 5
      delay = Stealth.config.dynamic_delay_muliplier * Stealth::Controller::DynamicDelay::SHORT_DELAY
      expect(controller).to receive(:sleep).exactly(1).times.with(delay)
      controller.say_offer_with_dynamic
    end

    it "should speed up SHORT_DELAY if dynamic_delay_muliplier < 1" do
      allow(stubbed_handler).to receive(:text).exactly(2).times
      allow(stubbed_handler).to receive(:delay).exactly(1).times
      allow(stubbed_client).to receive(:transmit).exactly(3).times

      Stealth.config.dynamic_delay_muliplier = 0.1
      delay = Stealth.config.dynamic_delay_muliplier * Stealth::Controller::DynamicDelay::SHORT_DELAY
      expect(controller).to receive(:sleep).exactly(1).times.with(delay)
      controller.say_offer_with_dynamic
    end
  end

  describe "variants" do
    let(:twilio_message) { SampleMessage.new(service: 'twilio') }
    let(:twilio_controller) { MessagesController.new(service_message: twilio_message.message_with_text) }

    let(:epsilon_message) { SampleMessage.new(service: 'epsilon') }
    let(:epsilon_controller) { MessagesController.new(service_message: epsilon_message.message_with_text) }

    let(:gamma_message) { SampleMessage.new(service: 'twitter') }
    let(:gamma_controller) { MessagesController.new(service_message: gamma_message.message_with_text) }

    it "should load the Facebook reply variant if current_service == facebook" do
      allow(controller.current_session).to receive(:flow_string).and_return("message")
      allow(controller.current_session).to receive(:state_string).and_return("say_hola")
      file_contents, selected_preprocessor = controller.send(:action_replies)

      expect(file_contents).to eq(File.read(File.expand_path("../replies/messages/say_hola.yml+facebook.erb", __dir__)))
    end

    it "should load the Twilio reply variant if current_service == twilio" do
      allow(twilio_controller.current_session).to receive(:flow_string).and_return("message")
      allow(twilio_controller.current_session).to receive(:state_string).and_return("say_hola")
      file_contents, selected_preprocessor = twilio_controller.send(:action_replies)

      expect(file_contents).to eq(File.read(File.expand_path("../replies/messages/say_hola.yml+twilio.erb", __dir__)))
    end

    it "should load the base reply variant if current_service does not have a custom variant" do
      allow(epsilon_controller.current_session).to receive(:flow_string).and_return("message")
      allow(epsilon_controller.current_session).to receive(:state_string).and_return("say_hola")
      file_contents, selected_preprocessor = epsilon_controller.send(:action_replies)

      expect(file_contents).to eq(File.read(File.expand_path("../replies/messages/say_hola.yml.erb", __dir__)))
    end

    it "should load the correct variant when there is no preprocessor" do
      allow(gamma_controller.current_session).to receive(:flow_string).and_return("message")
      allow(gamma_controller.current_session).to receive(:state_string).and_return("say_yo")
      file_contents, selected_preprocessor = gamma_controller.send(:action_replies)

      expect(file_contents).to eq(File.read(File.expand_path("../replies/messages/say_yo.yml+twitter", __dir__)))
    end
  end

  describe "randomized replies" do
    let(:stubbed_handler) { double("handler") }
    let(:stubbed_client) { double("client") }

    before(:each) do
      allow(Stealth::Services::Facebook::Client).to receive(:new).and_return(stubbed_client)
    end

    describe "text replies" do
      before(:each) do
        allow(controller.current_session).to receive(:flow_string).and_return("message")
        allow(controller.current_session).to receive(:state_string).and_return("say_randomize_text")
      end

      it "should receive a single text string" do
        allow(Stealth::Services::Facebook::ReplyHandler).to receive(:new) do |*args|
          expect(args.first[:reply]['text']).to be_a(String)
          stubbed_handler
        end
        allow(stubbed_handler).to receive(:text).exactly(1).times
        expect(stubbed_client).to receive(:transmit).exactly(1).times
        controller.say_randomize_text
      end
    end

    describe "text replies" do
      before(:each) do
        allow(controller.current_session).to receive(:flow_string).and_return("message")
        allow(controller.current_session).to receive(:state_string).and_return("say_randomize_speech")
      end

      it "should receive a single text string" do
        allow(Stealth::Services::Facebook::ReplyHandler).to receive(:new) do |*args|
          expect(args.first[:reply]['text']).to be_a(String)
          stubbed_handler
        end
        allow(stubbed_handler).to receive(:speech).exactly(1).times
        expect(stubbed_client).to receive(:transmit).exactly(1).times
        controller.say_randomize_speech
      end
    end
  end

end
