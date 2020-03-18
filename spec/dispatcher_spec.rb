# frozen_string_literal: true

require 'spec_helper'

describe "Stealth::Dispatcher" do

    class Stealth::Services::Facebook::MessageHandler

    end

    describe 'coordinate' do
      let(:dispatcher) {
        Stealth::Dispatcher.new(
          service: 'facebook',
          params: {},
          headers: {}
        )
      }

      it 'should call coordinate on the message handler' do
        message_handler = double
        expect(Stealth::Services::Facebook::MessageHandler).to receive(:new).and_return(message_handler)
        expect(message_handler).to receive(:coordinate)

        dispatcher.coordinate
      end
    end

    describe 'process' do
      class StubbedBotController < Stealth::Controller
        def route
          true
        end
      end

      let(:dispatcher) {
        Stealth::Dispatcher.new(
          service: 'facebook',
          params: {},
          headers: {}
        )
      }
      let(:fb_message) { SampleMessage.new(service: 'facebook') }
      let(:stubbed_controller) {
        StubbedBotController.new(service_message: fb_message.message_with_text)
      }

      it 'should call process on the message handler' do
        message_handler = double

        # Stub out the message handler to return a service_message
        expect(Stealth::Services::Facebook::MessageHandler).to receive(:new).and_return(message_handler)
        expect(message_handler).to receive(:process).and_return(fb_message.message_with_text)

        # Stub out BotController and set session
        expect(BotController).to receive(:new).and_return(stubbed_controller)
        stubbed_controller.current_session.set_session(new_flow: 'mr_tron', new_state: 'other_action')

        dispatcher.process
      end

      it 'should log the incoming message if transcript_logging is enabled' do
        message_handler = double

        # Stub out the message handler to return a service_message
        expect(Stealth::Services::Facebook::MessageHandler).to receive(:new).and_return(message_handler)
        expect(message_handler).to receive(:process).and_return(fb_message.message_with_text)

        # Stub out BotController and set session
        expect(BotController).to receive(:new).and_return(stubbed_controller)
        stubbed_controller.current_session.set_session(new_flow: 'mr_tron', new_state: 'other_action')

        Stealth.config.transcript_logging = true
        expect(dispatcher).to receive(:log_incoming_message).with(fb_message.message_with_text)
        dispatcher.process
      end
    end

end
