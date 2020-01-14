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

    it 'should normalize blank-padded messages' do
      test_controller.current_message.message = padded_msg
      expect(test_controller.normalized_msg).to eq('HELLO WORLD! 👋')
    end

    it 'should normalize differently cased messages' do
      test_controller.current_message.message = weird_case_msg
      expect(test_controller.normalized_msg).to eq('OH BABY OH BABY')
    end
  end

  describe "get_match" do
    it "should match messages with different casing" do
      test_controller.current_message.message = "NICE"
      expect(
        test_controller.get_match(['nice', 'woot'])
      ).to eq('nice')
    end

    it "should match messages with blank padding" do
      test_controller.current_message.message = " NiCe   "
      expect(
        test_controller.get_match(['nice', 'woot'])
      ).to eq('nice')
    end

    it "should match messages utilizing a lower case SMS quick reply" do
      test_controller.current_message.message = "a "
      expect(
        test_controller.get_match(['nice', 'woot'])
      ).to eq('nice')
    end

    it "should match messages utilizing an upper case SMS quick reply" do
      test_controller.current_message.message = " B "
      expect(
        test_controller.get_match(['nice', 'woot'])
      ).to eq('woot')
    end

    it "should raise Stealth::Errors::MessageNotRecognized if a response was not matched" do
      test_controller.current_message.message = "uh oh"
      expect {
        test_controller.get_match(['nice', 'woot'])
      }.to raise_error(Stealth::Errors::MessageNotRecognized)
    end

    it "should raise Stealth::Errors::MessageNotRecognized if an SMS quick reply was not matched" do
      test_controller.current_message.message = "C"
      expect {
        test_controller.get_match(['nice', 'woot'])
      }.to raise_error(Stealth::Errors::MessageNotRecognized)
    end

    describe "entity detection" do
      let(:no_intent) { :no }
      let(:yes_intent) { :yes }
      let(:single_number_nlp_result) { TestNlpResult::Luis.new(intent: yes_intent, entity: :single_number_entity) }
      let(:double_number_nlp_result) { TestNlpResult::Luis.new(intent: no_intent, entity: :double_number_entity) }
      let(:triple_number_nlp_result) { TestNlpResult::Luis.new(intent: yes_intent, entity: :triple_number_entity) }

      describe 'single nlp_result entity' do
        it 'should return the :number entity' do
          allow(test_controller).to receive(:perform_nlp!).and_return(single_number_nlp_result)
          test_controller.nlp_result = single_number_nlp_result

          test_controller.current_message.message = "hi"
          expect(
            test_controller.get_match(['nice', :number])
          ).to eq(test_controller.nlp_result.entities[:number].first)
        end

        it 'should return the first :number entity if fuzzy_match=true' do
          allow(test_controller).to receive(:perform_nlp!).and_return(double_number_nlp_result)
          test_controller.nlp_result = double_number_nlp_result

          test_controller.current_message.message = "hi"
          expect(
            test_controller.get_match(['nice', :number])
          ).to eq(test_controller.nlp_result.entities[:number].first)
        end

        it 'should raise Stealth::Errors::MessageNotRecognized if more than one :number entity is returned and fuzzy_match=false' do
          allow(test_controller).to receive(:perform_nlp!).and_return(double_number_nlp_result)
          test_controller.nlp_result = double_number_nlp_result

          test_controller.current_message.message = "hi"
          expect {
            test_controller.get_match(['nice', :number], fuzzy_match: false)
          }.to raise_error(Stealth::Errors::MessageNotRecognized, "Encountered 2 entity matches of type :number and expected 1. To allow, set fuzzy_match to true.")
        end
      end

      describe 'multiple nlp_result entity matches' do
        it 'should return the [:number, :number] entity' do
          allow(test_controller).to receive(:perform_nlp!).and_return(double_number_nlp_result)
          test_controller.nlp_result = double_number_nlp_result

          test_controller.current_message.message = "hi"
          expect(
            test_controller.get_match(['nice', [:number, :number]])
          ).to eq(double_number_nlp_result.entities[:number])
        end

        it 'should return the [:number, :number, :number] entity' do
          allow(test_controller).to receive(:perform_nlp!).and_return(triple_number_nlp_result)
          test_controller.nlp_result = triple_number_nlp_result

          test_controller.current_message.message = "hi"
          expect(
            test_controller.get_match(['nice', [:number, :number, :number]])
          ).to eq(triple_number_nlp_result.entities[:number])
        end

        it 'should return the [:number, :number] entity from a triple :number entity result' do
          allow(test_controller).to receive(:perform_nlp!).and_return(triple_number_nlp_result)
          test_controller.nlp_result = triple_number_nlp_result

          test_controller.current_message.message = "hi"
          expect(
            test_controller.get_match(['nice', [:number, :number]])
          ).to eq(triple_number_nlp_result.entities[:number].slice(0, 2))
        end

        it 'should return the :number entity from a triple :number entity result' do
          allow(test_controller).to receive(:perform_nlp!).and_return(triple_number_nlp_result)
          test_controller.nlp_result = triple_number_nlp_result

          test_controller.current_message.message = "hi"
          expect(
            test_controller.get_match(['nice', :number])
          ).to eq(triple_number_nlp_result.entities[:number].first)
        end

        it 'should return the [:number, :key_phrase] entities' do
          allow(test_controller).to receive(:perform_nlp!).and_return(triple_number_nlp_result)
          test_controller.nlp_result = triple_number_nlp_result

          test_controller.current_message.message = "hi"
          expect(
            test_controller.get_match(['nice', [:number, :key_phrase]])
          ).to eq([89, 'scores'])
        end

        it 'should raise Stealth::Errors::MessageNotRecognized if more than one :number entity is returned and fuzzy_match=false' do
          allow(test_controller).to receive(:perform_nlp!).and_return(triple_number_nlp_result)
          test_controller.nlp_result = triple_number_nlp_result

          test_controller.current_message.message = "hi"
          expect {
            test_controller.get_match(['nice', :number], fuzzy_match: false)
          }.to raise_error(Stealth::Errors::MessageNotRecognized, "Encountered 3 entity matches of type :number and expected 1. To allow, set fuzzy_match to true.")
        end

        it 'should raise Stealth::Errors::MessageNotRecognized if more than two :number entities are returned and fuzzy_match=false' do
          allow(test_controller).to receive(:perform_nlp!).and_return(triple_number_nlp_result)
          test_controller.nlp_result = triple_number_nlp_result

          test_controller.current_message.message = "hi"
          expect {
            test_controller.get_match(['nice', [:number, :number]], fuzzy_match: false)
          }.to raise_error(Stealth::Errors::MessageNotRecognized, "Encountered 1 additional entity matches of type :number for match [:number, :number]. To allow, set fuzzy_match to true.")
        end
      end
    end

    describe "mismatch" do
      describe 'raise_on_mismatch: true' do
        it "should raise a Stealth::Errors::MessageNotRecognized" do
          test_controller.current_message.message = 'C'
          expect {
            test_controller.get_match(['nice', 'woot'])
          }.to raise_error(Stealth::Errors::MessageNotRecognized)
        end

        it "should NOT log if an nlp_result is not present" do
          test_controller.current_message.message = 'spicy'
          expect(Stealth::Logger).to_not receive(:l)
          expect {
            test_controller.get_match(['nice', 'woot'])
          }.to raise_error(Stealth::Errors::MessageNotRecognized)
        end

        it "should log if an nlp_result is present" do
          test_controller.current_message.message = 'spicy'
          nlp_result = double('nlp_result')
          allow(nlp_result).to receive(:parsed_result).and_return({})

          expect(Stealth::Logger).to receive(:l).with(
            topic: :nlp,
            message: "NLP Result: {}"
          )

          test_controller.nlp_result = nlp_result

          expect {
            test_controller.get_match(['nice', 'woot'])
          }.to raise_error(Stealth::Errors::MessageNotRecognized)
        end
      end

      describe 'raise_on_mismatch: false' do
        it "should not raise a Stealth::Errors::MessageNotRecognized" do
          test_controller.current_message.message = 'C'
          expect {
            test_controller.get_match(['nice', 'woot'], raise_on_mismatch: false)
          }.to_not raise_error(Stealth::Errors::MessageNotRecognized)
        end

        it "should return the original message" do
          test_controller.current_message.message = 'spicy'
          expect(
            test_controller.get_match(['nice', 'woot'], raise_on_mismatch: false)
          ).to eq 'spicy'
        end

        it "should NOT log if an nlp_result is not present" do
          test_controller.current_message.message = 'spicy'
          expect(Stealth::Logger).to_not receive(:l)
          test_controller.get_match(['nice', 'woot'], raise_on_mismatch: false)
        end

        it "should log if an nlp_result is present" do
          test_controller.current_message.message = 'spicy'
          nlp_result = double('nlp_result')
          allow(nlp_result).to receive(:parsed_result).and_return({})

          expect(Stealth::Logger).to receive(:l).with(
            topic: :nlp,
            message: "NLP Result: {}"
          )

          test_controller.nlp_result = nlp_result

          test_controller.get_match(['nice', 'woot'], raise_on_mismatch: false)
        end
      end
    end
  end

  describe "handle_message" do
    it "should run the proc of the matched reply" do
      expect(STDOUT).to receive(:puts).with('Cool, Refinance 👍')

      test_controller.current_message.message = "B"
      test_controller.handle_message(
        'Buy' => proc { puts 'Buy' },
        'Refinance' => proc { puts 'Cool, Refinance 👍' }
      )
    end

    it "should run proc in the binding of the calling instance" do
      test_controller.current_message.message = "B"
      x = 0
      test_controller.handle_message(
        'Buy' => proc { x += 1 },
        'Refinance' => proc { x += 2 }
      )

      expect(x).to eq 2
    end

    describe "intent detection" do
      let(:no_intent) { :no }
      let(:yes_intent) { :yes }
      let(:yes_intent_nlp_result) { TestNlpResult::Luis.new(intent: yes_intent, entity: :single_number_entity) }
      let(:no_intent_nlp_result) { TestNlpResult::Luis.new(intent: no_intent, entity: :double_number_entity) }

      it 'should support :yes intent' do
        test_controller.current_message.message = "YAS"
        allow(test_controller).to receive(:perform_nlp!).and_return(yes_intent_nlp_result)
        test_controller.nlp_result = yes_intent_nlp_result

        x = 0
        test_controller.send(
          :handle_message, {
            'Buy' => proc { x += 1 },
            :yes => proc { x += 9 },
            :no => proc { x += 8 }
          }
        )

        expect(x).to eq 9
      end

      it 'should support :no intent' do
        test_controller.current_message.message = "NAH"
        allow(test_controller).to receive(:perform_nlp!).and_return(no_intent_nlp_result)
        test_controller.nlp_result = no_intent_nlp_result

        x = 0
        test_controller.send(
          :handle_message, {
            'Buy' => proc { x += 1 },
            :yes => proc { x += 9 },
            :no => proc { x += 8 }
          }
        )

        expect(x).to eq 8
      end
    end

    it "should raise Stealth::Errors::MessageNotRecognized if the reply does not match" do
      test_controller.current_message.message = "C"
      x = 0
      expect {
        test_controller.handle_message(
          'Buy' => proc { x += 1 },
          'Refinance' => proc { x += 2 }
        )
      }.to raise_error(Stealth::Errors::MessageNotRecognized)
    end

    it "should NOT log if an nlp_result is not present" do
      test_controller.current_message.message = 'spicy'
      expect(Stealth::Logger).to_not receive(:l)

      x = 0
      expect {
        test_controller.handle_message(
          'Buy' => proc { x += 1 },
          'Refinance' => proc { x += 2 }
        )
      }.to raise_error(Stealth::Errors::MessageNotRecognized)
    end

    it "should log if an nlp_result is present" do
      test_controller.current_message.message = 'spicy'
      nlp_result = double('nlp_result')
      allow(nlp_result).to receive(:parsed_result).and_return({})

      expect(Stealth::Logger).to receive(:l).with(
        topic: :nlp,
        message: "NLP Result: {}"
      )

      test_controller.nlp_result = nlp_result

      x = 0
      expect {
        test_controller.handle_message(
          'Buy' => proc { x += 1 },
          'Refinance' => proc { x += 2 }
        )
      }.to raise_error(Stealth::Errors::MessageNotRecognized)
    end
  end

end
