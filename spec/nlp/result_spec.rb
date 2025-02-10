# frozen_string_literal: true

require 'spec_helper'

describe "Stealth::Nlp::Result" do

  it 'should return the built-in entity types' do
    expect(Stealth::Nlp::Result::ENTITY_TYPES).to eq %i(number currency email percentage phone age
                      url ordinal geo dimension temp datetime duration
                      key_phrase name)
  end

  describe 'blank result' do
    let(:stealth_result) { Stealth::Nlp::Result.new(result: 1234) }

    it 'should initialize @result to the value provided during instantiation' do
      expect(stealth_result.result).to eq 1234
    end

    it 'should return nil for parsed_result' do
      expect(stealth_result.parsed_result).to be_nil
    end

    it 'should return nil for intent_id' do
      expect(stealth_result.intent_id).to be_nil
    end

    it 'should return nil for intent' do
      expect(stealth_result.intent).to be_nil
    end

    it 'should return nil for intent_score' do
      expect(stealth_result.intent_score).to be_nil
    end

    it 'should return {} for raw_entities' do
      expect(stealth_result.raw_entities).to eq({})
    end

    it 'should return {} for entities' do
      expect(stealth_result.entities).to eq({})
    end

    it 'should return nil for sentiment' do
      expect(stealth_result.sentiment).to be_nil
    end

    it 'should return nil for sentiment_score' do
      expect(stealth_result.sentiment_score).to be_nil
    end

    it 'should return false for present?' do
      expect(stealth_result.present?).to be false
    end
  end

end
