# frozen_string_literal: true

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "transition callbacks" do

  class KonamiCodeFlow
    include Stealth::Flow

    attr_reader :code, :before_transition_count, :transition_count

    def initialize
      @code = []
      @before_transition_count = 0
      @transition_count = 0
    end

    flow do
      state :up do
        event :upward, :transitions_to => :up
        event :downward, :transitions_to => :down
      end

      state :down do
        event :downward, :transitions_to => :down
        event :leftward, :transitions_to => :left
      end

      state :left do
        event :rightward, :transitions_to => :right
      end

      state :right do
        event :leftward, :transitions_to => :left
        event :bward, :transitions_to => :b
      end

      state :a

      state :b do
        event :award, :transitions_to => :a
      end

      before_transition do |from, to, triggering_event, *event_args|
        @before_transition_count += 1
      end

      after_transition do |from, to, triggering_event, *event_args|
        @code << to.to_s
      end

      on_transition {
        @transition_count += 1
      }
    end
  end

  let(:flow) { KonamiCodeFlow.new }

  before(:each) do
    flow.upward!
    flow.upward!
    flow.downward!
    flow.downward!
    flow.leftward!
    flow.rightward!
    flow.leftward!
    flow.rightward!
    flow.bward!
    flow.award!
  end

  it "should have a correct transition count" do
    expect(flow.transition_count).to eq 10
  end

  it "should have a correct before_transition count" do
    expect(flow.before_transition_count).to eq 10
  end

  it "should have generated the correct code via after_transition" do
    expect(flow.code).to eq(['up', 'up', 'down', 'down', 'left', 'right', 'left', 'right', 'b', 'a'])
  end

  describe "on_error callbacks" do
    class ErrorFlow
      include Stealth::Flow

      attr_reader :errors

      def initialize
        @errors = {}
      end

      flow do
        state :first do
          event :advance, :transitions_to => :second do
            raise "uh oh"
          end
        end

        state :second

        on_error do |error, from, to, event, *args|
          @errors.merge!({
            error: error.class,
            from: from,
            to: to,
            event: event,
            args: args
          })
        end
      end
    end

    let(:error_flow) { ErrorFlow.new }

    it "should not advance to the next state" do
      error_flow.advance!
      expect(error_flow.current_state).to eq :first
    end

    it "should call the on_error block" do
      error_flow.advance!
      expect(error_flow.errors).to eq({ error: RuntimeError, from: :first, to: :second, event: :advance, args: [] })
    end
  end

  describe "on_entry and on_exit callbacks" do
    class PostFlow
      include Stealth::Flow

      attr_reader :email_reviewer, :tweet_link

      def initialize
        @email_reviewer = false
        @tweet_link = false
      end

      flow do
        state :draft do
          event :submit_for_review, :transitions_to => :in_review

          on_exit do
            @email_reviewer = true
          end
        end

        state :in_review do
          event :approve, :transitions_to => :live
          event :reject, :transitions_to => :draft
        end

        state :live do
          on_entry do
            @tweet_link = true
          end
        end
      end
    end

    let(:post_flow) { PostFlow.new }

    it "should email the reviewer when flow transitions (on_exit) to in_review" do
      expect {
        post_flow.submit_for_review!
      }.to change(post_flow, :email_reviewer).from(false).to(true)
    end

    it "should tweet the post link when flow transitions (on_entry) to live" do
      post_flow.submit_for_review!

      expect {
        post_flow.approve!
      }.to change(post_flow, :tweet_link).from(false).to(true)
    end
  end

  describe "on_entry and on_exit method-style callbacks" do
    class ConcisePostFlow
      include Stealth::Flow

      attr_reader :email_reviewer, :tweet_link

      def initialize
        @email_reviewer = false
        @tweet_link = false
      end

      flow do
        state :draft do
          event :submit_for_review, :transitions_to => :in_review
        end

        state :in_review do
          event :approve, :transitions_to => :live
          event :reject, :transitions_to => :draft
        end

        state :live
      end

      def on_draft_exit(new_state, event, *args)
        @email_reviewer = true
      end

      def on_live_entry(prior_state, event, *args)
        @tweet_link = true
      end
    end

    let(:post_flow) { ConcisePostFlow.new }

    it "should email the reviewer when flow transitions (on_exit) to in_review" do
      expect {
        post_flow.submit_for_review!
      }.to change(post_flow, :email_reviewer).from(false).to(true)
    end

    it "should tweet the post link when flow transitions (on_entry) to live" do
      post_flow.submit_for_review!

      expect {
        post_flow.approve!
      }.to change(post_flow, :tweet_link).from(false).to(true)
    end
  end
end
