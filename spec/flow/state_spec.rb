# frozen_string_literal: true

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Stealth::Flow::State do

  class NewTodoFlow
    include Stealth::Flow

    flow do
      state :new

      state :get_due_date

      state :created

      state :error
    end
  end

  let(:flow) { NewTodoFlow.new }

  describe "flow states" do
    it "should convert itself to a string" do
      expect(flow.current_state.to_s).to be_a(String)
    end

    it "should convert itself to a symbol" do
      expect(flow.current_state.to_sym).to be_a(Symbol)
    end
  end

end
