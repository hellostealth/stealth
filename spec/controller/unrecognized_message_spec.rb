# frozen_string_literal: true

require 'spec_helper'

describe "Stealth::Controller::UnrecognizedMessage" do

  let(:fb_message) { SampleMessage.new(service: 'facebook') }
  let(:controller) { VadersController.new(service_message: fb_message.message_with_text) }

  describe 'run_unrecognized_message' do
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

    describe 'when UnrecognizedMessagesController is not defined' do
      before(:each) do
        Object.send(:remove_const, :UnrecognizedMessagesController)
      end

      it "should log and run catch_all" do
        expect(Stealth::Logger).to receive(:l).with(
          topic: 'unrecognized_message',
          message: "The message \"Hello World!\" was not recognized."
        ).ordered

        expect(Stealth::Logger).to receive(:l).with(
          topic: 'unrecognized_message',
          message: 'Running catch_all; UnrecognizedMessagesController not defined.'
        ).ordered

        expect(controller).to receive(:run_catch_all).with(err: e)
        controller.run_unrecognized_message(err: e)
      end
    end

    it "should call handle_unrecognized_message on the UnrecognizedMessagesController" do
      class UnrecognizedMessagesController < Stealth::Controller
        def handle_unrecognized_message
          do_nothing
        end
      end

      expect_any_instance_of(UnrecognizedMessagesController).to receive(:handle_unrecognized_message)
      controller.run_unrecognized_message(err: e)
    end

    it "should log if the UnrecognizedMessagesController#handle_unrecognized_message does not progress the session" do
      class UnrecognizedMessagesController < Stealth::Controller
        def handle_unrecognized_message
          # Oops
        end
      end

      expect(Stealth::Logger).to receive(:l).with(
        topic: 'unrecognized_message',
        message: "The message \"Hello World!\" was not recognized."
      ).ordered

      expect(Stealth::Logger).to receive(:l).with(
        topic: 'unrecognized_message',
        message: 'Did not send replies, update session, or step'
      ).ordered

      expect(controller).to_not receive(:run_catch_all)

      controller.run_unrecognized_message(err: e)
    end

    describe 'handoff to catch_all' do
      before(:each) do
        @session = Stealth::Session.new(id: controller.current_session_id)
        @session.set_session(new_flow: 'vader', new_state: 'action_with_unrecognized_msg')

        @error_slug = [
          'error',
          controller.current_session_id,
          'vader',
          'action_with_unrecognized_msg'
        ].join('-')

        $redis.del(@error_slug)
      end

      it "should catch StandardError within UnrecognizedMessagesController and run catch_all" do
        $err = Stealth::Errors::ReplyNotFound.new('oops')

        class UnrecognizedMessagesController < Stealth::Controller
          def handle_unrecognized_message
            raise $err
          end
        end

        expect(Stealth::Logger).to receive(:l).with(
          topic: 'unrecognized_message',
          message: "The message \"Hello World!\" was not recognized."
        ).ordered

        expect(controller).to receive(:run_catch_all).with(err: $err)

        controller.run_unrecognized_message(err: e)
      end

      it "should track the catch_all level against the original session during exceptions" do
        class UnrecognizedMessagesController < Stealth::Controller
          def handle_unrecognized_message
            raise 'oops'
          end
        end

        expect($redis.get(@error_slug)).to be_nil
        controller.run_unrecognized_message(err: e)
        expect($redis.get(@error_slug)).to eq '1'
      end

      it "should track the catch_all level against the original session for UnrecognizedMessage errors" do
        class UnrecognizedMessagesController < Stealth::Controller
          def handle_unrecognized_message
            handle_message(
              'x' => proc { do_nothing },
              'y' => proc { do_nothing }
            )
          end
        end

        expect($redis.get(@error_slug)).to be_nil
        controller.action(action: :action_with_unrecognized_msg)
        expect($redis.get(@error_slug)).to eq '1'
      end

      it "should NOT run catch_all if UnrecognizedMessagesController handles the message" do
        $x = 0
        class UnrecognizedMessagesController < Stealth::Controller
          def handle_unrecognized_message
            handle_message(
              'Hello World!' => proc {
                $x = 1
                do_nothing
              },
              'y' => proc { do_nothing }
            )
          end
        end

        expect($redis.get(@error_slug)).to be_nil
        controller.action(action: :action_with_unrecognized_msg)
        expect($redis.get(@error_slug)).to be_nil
        expect($x).to eq 1
      end
    end
  end

end
