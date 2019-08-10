# coding: utf-8
# frozen_string_literal: true

require 'spec_helper'

describe "Stealth::Lock" do
  let(:session_id) { SecureRandom.hex(14) }
  let(:session_slug) { 'hello->say_hello' }

  before(:each) do
    Stealth.config.lock_autorelease = 30
  end

  describe "create" do
    it "should raise an ArgumentError if the session_slug was not provided" do
      lock = Stealth::Lock.new(session_id: session_id)
      expect {
        lock.create
      }.to raise_error(ArgumentError)
    end

    it "should save the lock using a canonical key and value" do
      lock = Stealth::Lock.new(session_id: session_id, session_slug: session_slug)
      canonical_key = "#{session_id}-lock"
      expected_value = "#{lock.tid}##{session_slug}"
      lock.create
      expect($redis.get(canonical_key)).to eq expected_value
    end

    it "should include the reply file position in the lock" do
      lock = Stealth::Lock.new(
        session_id: session_id,
        session_slug: session_slug,
        position: 3
      )
      canonical_key = "#{session_id}-lock"
      expected_value = "#{lock.tid}##{session_slug}:3"
      lock.create
      expect($redis.get(canonical_key)).to eq expected_value
    end

    it "should set the lock expiration to lock_autorelease" do
      lock = Stealth::Lock.new(session_id: session_id, session_slug: session_slug)
      canonical_key = "#{session_id}-lock"
      expected_value = "#{lock.tid}##{session_slug}"
      lock.create
      expect($redis.ttl(canonical_key)).to be_between(1, 30).inclusive
    end
  end

  describe "release" do
    it "should delete the key in Redis" do
      lock = Stealth::Lock.new(session_id: session_id, session_slug: session_slug)
      canonical_key = "#{session_id}-lock"
      lock.create
      expect($redis.get(canonical_key)).to_not be_nil
      lock.release
      expect($redis.get(canonical_key)).to be_nil
    end
  end

  describe "slug" do
    it "should return the lock slug from Redis" do
      lock = Stealth::Lock.new(session_id: session_id, session_slug: session_slug)
      lock.create
      canonical_key = "#{session_id}-lock"
      expect(lock.slug).to eq "#{lock.tid}##{session_slug}"
    end
  end

  describe "flow_and_state" do
    it "should return a hash containing the flow and state" do
      lock = Stealth::Lock.new(session_id: session_id, session_slug: session_slug)
      expect(lock.flow_and_state[:flow]).to eq 'hello'
      expect(lock.flow_and_state[:state]).to eq 'say_hello'
    end
  end

  describe "self.find_lock" do
    it "should load the lock from Redis" do
      lock_key = "#{session_id}-lock"
      example_tid = 'ovefhgJvx'
      example_session = 'goodbye->say_goodbye'
      example_position = 2
      example_lock = "#{example_tid}##{example_session}:#{example_position}"
      $redis.set(lock_key, example_lock)

      lock = Stealth::Lock.find_lock(session_id: session_id)
      expect(lock.tid).to eq example_tid
      expect(lock.session_slug).to eq example_session
      expect(lock.position).to eq example_position
    end

    it "should return nil if the lock is not found" do
      lock_key = "#{session_id}-lock"
      lock = Stealth::Lock.find_lock(session_id: session_id)
      expect($redis.get(lock_key)).to be_nil
      expect(lock).to be_nil
    end
  end
end
