# frozen_string_literal: true

require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

class NewTodoFlow
  include Stealth::Flow

  flow do
    state :new

    state :get_due_date

    state :created, fails_to: :new

    state :error
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
    class MarcoFlow
      include Stealth::Flow

      flow do
        state :polo
      end
    end

    let(:session) do
      session = Stealth::Session.new(user_id: user_id)
      session.set(flow: 'Marco', state: 'polo')
      session
    end

    it "should return the flow" do
      expect(session.flow).to be_a(MarcoFlow)
    end

    it "should return the state" do
      expect(session.state).to be_a(Stealth::Flow::State)
      expect(session.state).to eq :polo
    end

    it "should return the flow_string" do
      expect(session.flow_string).to eq "Marco"
    end

    it "should return the state_string" do
      expect(session.state_string).to eq "polo"
    end

    it "should respond to present? and blank?" do
      expect(session.present?).to be true
      expect(session.blank?).to be false
    end
  end

end
