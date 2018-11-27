# coding: utf-8
# frozen_string_literal: true

require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

class FlowMap
  include Stealth::Flow

  flow :new_todo do
    state :new
    state :get_due_date
    state :created, fails_to: :new
    state :error
  end

  flow :marco do
    state :polo
  end
end

describe "Stealth::Session" do
  let(:user_id) { '0xDEADBEEF' }

  it "should raise an error if $redis is not set" do
    $redis = nil

    expect {
      Stealth::Session.new(user_id: user_id)
    }.to raise_error(Stealth::Errors::RedisNotConfigured)

    $redis = MockRedis.new
  end

  describe "without a session" do
    let(:session) { Stealth::Session.new(user_id: user_id) }

    it "should have nil flow and state" do
      expect(session.flow).to be_nil
      expect(session.state).to be_nil
    end

    it "should have nil flow_string and state_string" do
      expect(session.flow_string).to be_nil
      expect(session.state_string).to be_nil
    end

    it "should respond to present? and blank?" do
      expect(session.present?).to be false
      expect(session.blank?).to be true
    end
  end

  describe "with a session" do
    let(:session) do
      session = Stealth::Session.new(user_id: user_id)
      session.set(flow: 'marco', state: 'polo')
      session
    end

    it "should return the FlowMap" do
      expect(session.flow).to be_a(FlowMap)
    end

    it "should return the state" do
      expect(session.state).to be_a(Stealth::Flow::State)
      expect(session.state).to eq :polo
    end

    it "should return the flow_string" do
      expect(session.flow_string).to eq "marco"
    end

    it "should return the state_string" do
      expect(session.state_string).to eq "polo"
    end

    it "should respond to present? and blank?" do
      expect(session.present?).to be true
      expect(session.blank?).to be false
    end
  end

  describe "incrementing and decrementing" do
    let(:session) { Stealth::Session.new(user_id: user_id) }

    it "should increment the state" do
      session.set(flow: 'new_todo', state: 'get_due_date')
      new_session = session + 1.state
      expect(new_session.state_string).to eq('created')
    end

    it "should decrement the state" do
      session.set(flow: 'new_todo', state: 'error')
      new_session = session - 2.states
      expect(new_session.state_string).to eq('get_due_date')
    end

    it "should return the first state if the decrement is out of bounds" do
      session.set(flow: 'new_todo', state: 'get_due_date')
      new_session = session - 5.states
      expect(new_session.state_string).to eq('new')
    end

    it "should return the last state if the increment is out of bounds" do
      session.set(flow: 'new_todo', state: 'created')
      new_session = session + 5.states
      expect(new_session.state_string).to eq('error')
    end
  end

  describe "self.is_a_session_string?" do
    it "should return false for state strings" do
      session_string = 'say_hello'
      expect(Stealth::Session.is_a_session_string?(session_string)).to be false
    end

    it "should return false for an incomplete session string" do
      session_string = 'hello->'
      expect(Stealth::Session.is_a_session_string?(session_string)).to be false
    end

    it "should return true for a complete session string" do
      session_string = 'hello->say_hello'
      expect(Stealth::Session.is_a_session_string?(session_string)).to be true
    end
  end
end
