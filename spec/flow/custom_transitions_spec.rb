# frozen_string_literal: true

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "custom transitions" do

  class FetchTodosFlow
    include Stealth::Flow

    flow do
      state :todays_todos do
        event :fetch_tomorrows_todos, :transitions_to => :tomorrows_todos
        event :fetch_yesterdays_todos, :transitions_to => :yesterdays_todos
      end

      state :tomorrows_todos do
        event :view_todo, :transitions_to => :show
        event :edit_todo, :transitions_to => :edit
      end

      state :tomorrows_todos do
        event :view_todo, :transitions_to => :show
        event :edit_todo, :transitions_to => :edit
      end

      state :show

      state :edit do
        event :save_todo, :transitions_to => :show
        event :error_in_input, :transitions_to => :error
      end

      state :error
    end

    def view_todo(todo_id)
      unless todo_id > 0
        halt('ID is not valid.')
      end

      :the_todo
    end

    def edit_todo(todo_id)
      unless todo_id > 0
        halt('ID is not valid.')
      end

      :edit_todo_view
    end

    def save_todo(params)
      if params.nil?
        halt!('Invalid todo params specified.')
      end

      :todo_saved
    end
  end

  let(:flow) { FetchTodosFlow.new }

  it "should transition via custom transition methods" do
    flow.fetch_tomorrows_todos!
    expect(flow.view_todo!(1)).to eq :the_todo
    expect(flow.current_state).to eq :show
  end

  it "should follow multiple custom transitions" do
    flow.fetch_tomorrows_todos!
    expect(flow.edit_todo!(1)).to eq :edit_todo_view
    expect(flow.current_state).to eq :edit

    expect(flow.save_todo!({ task: 'test' })).to eq :todo_saved
    expect(flow.current_state).to eq :show
  end

  describe "halting transitions" do
    it "should halt the transition when halt() is called" do
      flow.fetch_tomorrows_todos!
      flow.view_todo!(-1)
      expect(flow.current_state).to eq :tomorrows_todos
      expect(flow.halted_because).to eq "ID is not valid."
    end

    it "should halt the transition when halt!() is called and raise Stealth::Flow::TransitionHalted" do
      flow.fetch_tomorrows_todos!
      flow.edit_todo!(1)
      expect(flow.current_state).to eq :edit

      expect {
        flow.save_todo!(nil)
      }.to raise_error(Stealth::Flow::TransitionHalted)

      expect(flow.halted_because).to eq "Invalid todo params specified."
    end
  end

end
