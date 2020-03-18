# frozen_string_literal: true

require 'spec_helper'

describe "Stealth::Redis" do

  class RedisTester
    include Stealth::Redis
  end

  let(:redis_tester) { RedisTester.new }
  let(:key) { 'xyz' }

  describe "get_key" do
    it "should return the key from Redis if an expiration is not set" do
      $redis.set(key, 'abc')
      expect(redis_tester.send(:get_key, key)).to eq 'abc'
    end

    it "should call getex if an expiration is set" do
      expect(redis_tester).to receive(:getex).with(key, 30)
      redis_tester.send(:get_key, key, expiration: 30)
    end
  end

  describe "delete_key" do
    it 'should delete the key from Redis' do
      $redis.set(key, 'abc')
      expect(redis_tester.send(:get_key, key)).to eq 'abc'
      redis_tester.send(:delete_key, key)
      expect(redis_tester.send(:get_key, key)).to be_nil
    end
  end

  describe "getex" do
    it "should return the key from Redis" do
      Stealth.config.session_ttl = 50
      $redis.set(key, 'abc')
      expect(redis_tester.send(:getex, key)).to eq 'abc'
    end

    it "should set the expiration of a key in Redis" do
      Stealth.config.session_ttl = 50
      $redis.set(key, 'abc')
      redis_tester.send(:getex, key)
      expect($redis.ttl(key)).to be_between(0, 50).inclusive
    end

    it "should update the expiration of a key in Redis" do
      Stealth.config.session_ttl = 500
      $redis.setex(key, 50, 'abc')
      redis_tester.send(:getex, key)
      expect($redis.ttl(key)).to be_between(400, 500).inclusive
    end
  end

  describe "persist_key" do
    it "should set the key in Redis" do
      Stealth.config.session_ttl = 50
      redis_tester.send(:persist_key, key: key, value: 'zzz')
      expect($redis.get(key)).to eq 'zzz'
    end

    it "should set the expiration to session_ttl if none specified" do
      Stealth.config.session_ttl = 50
      redis_tester.send(:persist_key, key: key, value: 'zzz')
      expect($redis.ttl(key)).to be_between(0, 50).inclusive
    end

    it "should set the expiration to the specified value when provided" do
      Stealth.config.session_ttl = 50
      redis_tester.send(:persist_key, key: key, value: 'zzz', expiration: 500)
      expect($redis.ttl(key)).to be_between(400, 500).inclusive
    end
  end

end
