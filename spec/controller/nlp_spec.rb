# frozen_string_literal: true

require 'spec_helper'

describe Stealth::Controller::Nlp do

  let(:fb_message) { SampleMessage.new(service: 'facebook') }
  let(:controller) { VadersController.new(service_message: fb_message.message_with_text) }

  describe 'nlp_client_klass' do
    it 'should return the correct class for LUIS' do
      config_dbl = double('Stealth Config', nlp_integration: :luis).as_null_object
      allow(Stealth).to receive(:config).and_return(config_dbl)
      expect(controller.send(:nlp_client_klass)).to eq Stealth::Nlp::Luis::Client
    end

    it 'should return the correct class for Dialogflow' do
      config_dbl = double('Stealth Config', nlp_integration: :dialogflow).as_null_object
      allow(Stealth).to receive(:config).and_return(config_dbl)
      expect(controller.send(:nlp_client_klass)).to eq Stealth::Nlp::Dialogflow::Client
    end

    it 'should raise an error if it cannot locate a class' do
      config_dbl = double('Stealth Config', nlp_integration: :unknown).as_null_object
      allow(Stealth).to receive(:config).and_return(config_dbl)
      expect {
        controller.send(:nlp_client_klass)
      }.to raise_error(NameError)
    end
  end

  describe 'perform_nlp!' do

    describe 'NLP has not yet been configured' do
      it 'should raise Stealth::Errors::ConfigurationError' do
        config_dbl = double('Stealth Config', nlp_integration: nil).as_null_object
        allow(Stealth).to receive(:config).and_return(config_dbl)

        expect {
          controller.perform_nlp!
        }.to raise_error(Stealth::Errors::ConfigurationError)
      end
    end

    describe 'NLP has been configured' do
      before(:each) do
        config_dbl = double('Stealth Config', nlp_integration: :luis).as_null_object
        @luis_client_dbl = double('LUIS Client')
        allow(Stealth).to receive(:config).and_return(config_dbl)
        allow(Stealth::Nlp::Luis::Client).to receive(:new).and_return(@luis_client_dbl)
      end

      let(:nlp_result) { Stealth::Nlp::Result.new(result: {}) }

      it 'should call understand on the NLP client' do
        expect(@luis_client_dbl).to receive(:understand).with(query: 'Hello World!').and_return(nlp_result)
        controller.perform_nlp!
      end

      it 'should return an Nlp::Result object' do
        expect(@luis_client_dbl).to receive(:understand).with(query: 'Hello World!').and_return(nlp_result)
        expect(controller.perform_nlp!).to eq nlp_result
      end

      it 'should memoize the understand call' do
        expect(@luis_client_dbl).to receive(:understand).once.with(query: 'Hello World!').and_return(nlp_result)
        controller.perform_nlp!
        controller.perform_nlp!
        controller.perform_nlp!
      end

      it 'should store the nlp_result for the current controller' do
        expect(@luis_client_dbl).to receive(:understand).once.with(query: 'Hello World!').and_return(nlp_result)
        controller.perform_nlp!
        expect(controller.nlp_result).to eq nlp_result
      end

      it 'should store the nlp_result for the current service_message' do
        expect(@luis_client_dbl).to receive(:understand).once.with(query: 'Hello World!').and_return(nlp_result)
        controller.perform_nlp!
        expect(controller.current_message.nlp_result).to eq nlp_result
      end
    end
  end

end
