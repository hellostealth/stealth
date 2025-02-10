# frozen_string_literal: true

require 'spec_helper'

describe "Stealth::Nlp::Client" do

  describe 'blank client' do
    let(:nlp_client) { Stealth::Nlp::Client.new }

    it 'should return nil for client' do
      expect(nlp_client.client).to be_nil
    end

    it 'should return nil for the understand call' do
      expect(nlp_client.understand(query: 'hello world!')).to be_nil
    end

    it 'should return nil for the understand_speec call' do
      expect(nlp_client.understand_speech(audio_file: 'https://path.to/audio.mp3')).to be_nil
    end
  end

end
