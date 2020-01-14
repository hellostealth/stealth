# frozen_string_literal: true

require 'spec_helper'

describe "Stealth::Controller::InterruptDetect" do

  let(:fb_message) { SampleMessage.new(service: 'facebook') }
  let(:controller) { VadersController.new(service_message: fb_message.message_with_text) }
  let(:lock_key) { "#{fb_message.sender_id}-lock" }
  let(:example_tid) { 'ovefhgJvx' }
  let(:example_session) { 'goodbye->say_goodbye' }
  let(:example_position) { 2 }
  let(:example_lock) { "#{example_tid}##{example_session}:#{example_position}" }

  describe 'current_lock' do
    it "should return the current lock for the session if it is locked" do
      $redis.set(lock_key, example_lock)
      current_lock = controller.current_lock
      expect(current_lock).to be_a(Stealth::Lock)
      expect(current_lock.session_id).to eq fb_message.sender_id
    end

    it "should return nil if the current session is not locked" do
      random_lock_key = "xyz123-lock"

      # clear the memoization
      controller.instance_eval do
        @current_lock = nil
        @current_session_id = random_lock_key
      end

      expect($redis.get(random_lock_key)).to be_nil
      expect(controller.current_lock).to be_nil
    end
  end

  describe 'run_interrupt_action' do
    let(:interrupts_controller) { InterruptController.new(service_message: fb_message) }

    it "should return false if an InterruptsController is not defined" do
      expect(Stealth::Logger).to receive(:l).with(
        topic: 'interrupt',
        message: "Interrupt detected for session #{fb_message.sender_id}"
      ).ordered

      expect(Stealth::Logger).to receive(:l).with(
        topic: 'interrupt',
        message: 'Ignoring interrupt; InterruptsController not defined.'
      ).ordered

      expect(controller.run_interrupt_action).to be false
    end

    it "should call say_interrupted on the InterruptsController" do
      class InterruptsController < Stealth::Controller
        def say_interrupted
        end
      end

      expect_any_instance_of(InterruptsController).to receive(:say_interrupted)
      controller.run_interrupt_action
    end

    it "should log if the InterruptsController#say_interrupted does not progress the session" do
      class InterruptsController < Stealth::Controller
        def say_interrupted
        end
      end

      expect(Stealth::Logger).to receive(:l).with(
        topic: 'interrupt',
        message: "Interrupt detected for session #{fb_message.sender_id}"
      ).ordered

      expect(Stealth::Logger).to receive(:l).with(
        topic: 'interrupt',
        message: 'Did not send replies, update session, or step'
      ).ordered

      controller.run_interrupt_action
    end

    it "should catch StandardError from InterruptController and log it" do
      class InterruptsController < Stealth::Controller
        def say_interrupted
          raise Stealth::Errors::ReplyNotFound
        end
      end

      # Once for the interrupt detection, once for the error
      expect(Stealth::Logger).to receive(:l).exactly(2).times

      controller.run_interrupt_action
    end
  end

  describe 'interrupt_detected?' do
    it "should return false if there is not a lock on the session" do
      random_lock_key = "xyz123-lock"

      # clear the memoization
      controller.instance_eval do
        @current_lock = nil
        @current_session_id = random_lock_key
      end

      expect(controller.send(:interrupt_detected?)).to be false
    end

    it "should return false if the current thread owns the lock" do
      $redis.set(lock_key, example_lock)
      lock = controller.current_lock
      expect(lock).to receive(:tid).and_return(Stealth.tid)

      expect(controller.send(:interrupt_detected?)).to be false
    end

    it 'should return true if the session is locked by another thread' do
      $redis.set(lock_key, example_lock)
      # our mock tid will not match the real tid for this test
      expect(controller.send(:interrupt_detected?)).to be true
    end
  end

  describe 'current_thread_has_control?' do
    it "should return true if the current tid matches the lock tid" do
      $redis.set(lock_key, example_lock)
      lock = controller.current_lock
      expect(lock).to receive(:tid).and_return(Stealth.tid)
      expect(controller.send(:current_thread_has_control?)).to be true
    end

    it "should return false if the current tid does not match the lock tid" do
      $redis.set(lock_key, example_lock)
      lock = controller.current_lock
      expect(controller.send(:current_thread_has_control?)).to be false
    end
  end

  describe 'lock_session!' do
    it "should create a lock for the session" do
      $redis.del(lock_key)
      controller.send(:lock_session!, session_slug: example_session, position: example_position)
      expect($redis.get(lock_key)).to match(/goodbye\-\>say_goodbye\:2/)
    end
  end

  describe 'release_lock!' do
    it "should not raise an error if current_lock is nil" do
      expect(controller).to receive(:current_lock).and_return(nil)
      controller.send(:release_lock!)
    end

    it "should not release the lock if we are in the InterruptsController" do
      class InterruptsController
      end

      lock = controller.current_lock
      expect(controller).to receive(:class).and_return InterruptsController
      expect(lock).to_not receive(:release)
      controller.send(:release_lock!)
    end

    it "should release the lock if there is one and we are not in the InterruptsController" do
      $redis.set(lock_key, example_lock)
      controller.send(:release_lock!)
      expect($redis.get(lock_key)).to be_nil
    end
  end

end
