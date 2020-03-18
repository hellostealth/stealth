class VadersController < Stealth::Controller
  def my_action
    raise "oops"
  end

  def my_action2

  end

  def my_action3
    do_nothing
  end

  def action_with_unrecognized_msg
    handle_message(
      'hello' => proc { puts "Hello world!" },
      'bye' => proc { puts "Goodbye world!" }
    )
  end

  def action_with_unrecognized_match
    match = get_match(['hello', 'bye'])
  end
end
