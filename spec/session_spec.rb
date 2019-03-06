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
      session.set(new_flow: 'marco', new_state: 'polo')
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
      session.set(new_flow: 'new_todo', new_state: 'get_due_date')
      new_session = session + 1.state
      expect(new_session.state_string).to eq('created')
    end

    it "should decrement the state" do
      session.set(new_flow: 'new_todo', new_state: 'error')
      new_session = session - 2.states
      expect(new_session.state_string).to eq('get_due_date')
    end

    it "should return the first state if the decrement is out of bounds" do
      session.set(new_flow: 'new_todo', new_state: 'get_due_date')
      new_session = session - 5.states
      expect(new_session.state_string).to eq('new')
    end

    it "should return the last state if the increment is out of bounds" do
      session.set(new_flow: 'new_todo', new_state: 'created')
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

  describe "self.canonical_session_slug" do
    it "should generate a canonical session slug given a flow and state as symbols" do
      expect(
        Stealth::Session.canonical_session_slug(flow: :hello, state: :say_hello)
      ).to eq 'hello->say_hello'
    end

    it "should generate a canonical session slug given a flow and state as strings" do
      expect(
        Stealth::Session.canonical_session_slug(flow: 'hello', state: 'say_hello')
      ).to eq 'hello->say_hello'
    end
  end

  describe "self.flow_and_state_from_session_slug" do
    it "should return the flow and string as a hash with symbolized keys" do
      slug = 'hello->say_hello'
      expect(
        Stealth::Session.flow_and_state_from_session_slug(slug: slug)
      ).to eq({ flow: 'hello', state: 'say_hello' })
    end

    it "should not raise if slug is nil" do
      slug = nil
      expect(
        Stealth::Session.flow_and_state_from_session_slug(slug: slug)
      ).to eq({ flow: nil, state: nil })
    end
  end

  describe "setting sessions" do
    let(:session) { Stealth::Session.new(user_id: user_id) }
    let(:previous_session) { Stealth::Session.new(user_id: user_id, previous: true) }

    before(:each) do
      $redis.del(user_id)
      $redis.del([user_id, 'previous'].join('-'))
    end

    it "should store the new session" do
      session.set(new_flow: 'marco', new_state: 'polo')
      expect($redis.get(user_id)).to eq 'marco->polo'
    end

    it "should store the current_session to previous_session" do
      $redis.set(user_id, 'new_todo->new')
      $redis.set([user_id, 'previous'].join('-'), 'new_todo->error')
      session.set(new_flow: 'marco', new_state: 'polo')
      expect(previous_session.get).to eq 'new_todo->new'
    end

    it "should not update previous_session if it matches current_session" do
      $redis.set(user_id, 'marco->polo')
      $redis.set([user_id, 'previous'].join('-'), 'new_todo->new')
      session.set(new_flow: 'marco', new_state: 'polo')
      expect(previous_session.get).to eq 'new_todo->new'
    end

    it "should set an expiration for current_session if session_ttl is specified" do
      Stealth.config.session_ttl = 500
      session.set(new_flow: 'marco', new_state: 'polo')
      expect($redis.ttl(user_id)).to be > 0
      Stealth.config.session_ttl = 0
    end

    it "should set an expiration for previous_session if session_ttl is specified" do
      Stealth.config.session_ttl = 500
      $redis.set(user_id, 'new_todo->new')
      session.set(new_flow: 'marco', new_state: 'polo')
      expect($redis.ttl([user_id, 'previous'].join('-'))).to be > 0
      Stealth.config.session_ttl = 0
    end

    it "should NOT set an expiration if session_ttl is not specified" do
      Stealth.config.session_ttl = 0
      session.set(new_flow: 'new_todo', new_state: 'get_due_date')
      expect($redis.ttl(user_id)).to eq -1 # Does not expire
    end
  end

  describe "getting sessions" do
    let(:session) { Stealth::Session.new(user_id: user_id) }
    let(:previous_session) { Stealth::Session.new(user_id: user_id, previous: true) }

    before(:each) do
      $redis.del(user_id)
      $redis.del([user_id, 'previous'].join('-'))
    end

    it "should return the stored current_session" do
      session.set(new_flow: 'marco', new_state: 'polo')
      expect(session.get).to eq 'marco->polo'
    end

    it "should return the stored previous_session if previous is requested" do
      $redis.set(user_id, 'new_todo->new')
      session.set(new_flow: 'marco', new_state: 'polo')
      expect(previous_session.get).to eq 'new_todo->new'
    end

    it "should update the expiration of current_session if session_ttl is set" do
      Stealth.config.session_ttl = 50
      session.set(new_flow: 'marco', new_state: 'polo')
      expect($redis.ttl(user_id)).to be_between(0, 50).inclusive

      Stealth.config.session_ttl = 500
      session.session = nil # reset memoization
      session.get
      expect($redis.ttl(user_id)).to be > 100

      Stealth.config.session_ttl = 0
    end
  end
end
