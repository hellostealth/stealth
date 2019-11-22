# frozen_string_literal: true

require 'spec_helper'

describe Stealth::Controller::Messages do

  class MrTronsController < Stealth::Controller

  end

  let(:facebook_message) { SampleMessage.new(service: 'facebook') }
  let(:test_controller) {
    MrTronsController.new(service_message: facebook_message.message_with_text)
  }

  describe "normalized_msg" do
    let(:padded_msg) { '  Hello World! 👋  ' }
    let(:weird_case_msg) { 'Oh BaBy Oh BaBy' }

    it 'should normalize padded messages' do
      test_controller.current_message.message = padded_msg
      expect(test_controller.send(:normalized_msg)).to eq('HELLO WORLD! 👋')
    end

    it 'should normalize differently cased messages' do
      test_controller.current_message.message = weird_case_msg
      expect(test_controller.send(:normalized_msg)).to eq('OH BABY OH BABY')
    end
  end

  describe "get_match" do
    it "should match messages with different casing" do
      test_controller.current_message.message = "NICE"
      expect(
        test_controller.send(:get_match, ['nice', 'woot'])
      ).to eq('nice')
    end

    it "should match messages with blank padding" do
      test_controller.current_message.message = " NiCe   "
      expect(
        test_controller.send(:get_match, ['nice', 'woot'])
      ).to eq('nice')
    end

    it "should match messages utilizing a lower case SMS quick reply" do
      test_controller.current_message.message = "a "
      expect(
        test_controller.send(:get_match, ['nice', 'woot'])
      ).to eq('nice')
    end

    it "should match messages utilizing an upper case SMS quick reply" do
      test_controller.current_message.message = " B "
      expect(
        test_controller.send(:get_match, ['nice', 'woot'])
      ).to eq('woot')
    end

    it "should raise StandardError if a response was not matched" do
      test_controller.current_message.message = "uh oh"
      expect {
        test_controller.send(:get_match, ['nice', 'woot'])
      }.to raise_error(StandardError)
    end

    it "should raise StandardError if an SMS quick reply was not matched" do
      test_controller.current_message.message = "C"
      expect {
        test_controller.send(:get_match, ['nice', 'woot'])
      }.to raise_error(StandardError)
    end

    # describe "yes matchers" do
    #   it 'should return :yes if a yes-like response is received' do
    #     test_controller.current_message.message = "yup"
    #     expect(
    #       test_controller.send(:get_match, ['nice', :yes, :no])
    #     ).to eq(:yes)
    #   end

    #   it 'should utilize message_is_a_yes?' do
    #     expect(test_controller).to receive(:message_is_a_yes?).and_return(true)
    #     test_controller.current_message.message = "YUP"
    #     test_controller.send(:get_match, ['nice', :yes, :no])
    #   end
    # end

    # describe "no matchers" do
    #   it 'should return :no if a no-like response is received' do
    #     test_controller.current_message.message = "nah"
    #     expect(
    #       test_controller.send(:get_match, ['nice', :yes, :no])
    #     ).to eq(:no)
    #   end

    #   it 'should utilize message_is_a_no?' do
    #     expect(test_controller).to receive(:message_is_a_no?).and_return(true)
    #     test_controller.current_message.message = "NAH"
    #     test_controller.send(:get_match, ['nice', :yes, :no])
    #   end
    # end

    describe 'raise_on_mismatch: false' do
      it "should not raise a StandardError if raise_on_mismatch = false" do
        test_controller.current_message.message = 'C'
        expect {
          test_controller.send(:get_match, ['nice', 'woot'], raise_on_mismatch: false)
        }.to_not raise_error(StandardError)
      end

      it "should return the original message if raise_on_mismatch = false" do
        test_controller.current_message.message = 'spicy'
        expect(
          test_controller.send(:get_match, ['nice', 'woot'], raise_on_mismatch: false)
        ).to eq 'spicy'
      end
    end
  end

  describe "handle_response" do
    it "should run the proc of the matched reply" do
      expect(STDOUT).to receive(:puts).with('Cool, Refinance 👍')

      test_controller.current_message.message = "B"
      test_controller.send(
        :handle_response, {
          'Buy' => proc { puts 'Buy' },
          'Refinance' => proc { puts 'Cool, Refinance 👍' }
        }
      )
    end

    it "should run proc in the binding of the calling instance" do
      test_controller.current_message.message = "B"
      x = 0
      test_controller.send(
        :handle_response, {
          'Buy' => proc { x += 1 },
          'Refinance' => proc { x += 2 }
        }
      )

      expect(x).to eq 2
    end

    # it 'should support :yes keys' do
    #   test_controller.current_message.message = "YAS"
    #   x = 0
    #   test_controller.send(
    #     :handle_response, {
    #       'Buy' => proc { x += 1 },
    #       :yes => proc { x += 9 }
    #     }
    #   )

    #   expect(x).to eq 9
    # end

    # it 'should support :no keys' do
    #   test_controller.current_message.message = "negative"
    #   x = 0
    #   test_controller.send(
    #     :handle_response, {
    #       'Buy' => proc { x += 1 },
    #       :no => proc { x += 5 }
    #     }
    #   )

    #   expect(x).to eq 5
    # end

    it "should raise StandardError if the reply does not match" do
      test_controller.current_message.message = "C"
      x = 0
      expect {
        test_controller.send(
          :handle_response, {
            'Buy' => proc { x += 1 },
            'Refinance' => proc { x += 2 }
          }
        )
      }.to raise_error(StandardError)
    end
  end

end
