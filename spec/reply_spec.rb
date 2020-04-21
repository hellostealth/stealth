# frozen_string_literal: true

require 'spec_helper'

describe "Stealth::Reply" do

  let!(:unstructured_text) {
    { 'reply_type' => 'text', 'text' => 'Hello World!' }
  }
  let!(:unstructured_delay) {
    { 'reply_type' => 'delay', 'duration' => 'dynamic' }
  }
  let(:text_reply) { Stealth::Reply.new(unstructured_reply: unstructured_text) }
  let(:delay_reply) { Stealth::Reply.new(unstructured_reply: unstructured_delay) }

  describe 'hash-like [] getter' do
    it 'should return the values' do
      expect(text_reply['text']).to eq 'Hello World!'
      expect(delay_reply['duration']).to eq 'dynamic'
    end
  end

  describe 'hash-like []= setter' do
    it 'should return the values' do
      text_reply['woot'] = 'root'
      delay_reply['duration'] = 4.3
      expect(text_reply['woot']).to eq 'root'
      expect(delay_reply['duration']).to eq 4.3
    end
  end

  describe 'reply_type' do
    it 'should act as a getter method for reply_type' do
      expect(text_reply.reply_type).to eq 'text'
      expect(delay_reply.reply_type).to eq 'delay'
    end
  end

  describe 'delay?' do
    it 'should return false for a text reply' do
      expect(text_reply.delay?).to be false
    end

    it 'should return true for a delay reply' do
      expect(delay_reply.delay?).to be true
    end
  end

  describe 'self.dynamic_delay' do
    it 'should return a new Stealth::Reply' do
      expect(Stealth::Reply.dynamic_delay).to be_a(Stealth::Reply)
    end

    it 'should be a dynamic delay' do
      expect(Stealth::Reply.dynamic_delay.delay?).to be true
      expect(Stealth::Reply.dynamic_delay.reply_type).to eq 'delay'
      expect(Stealth::Reply.dynamic_delay['duration']).to eq 'dynamic'
    end
  end

end
