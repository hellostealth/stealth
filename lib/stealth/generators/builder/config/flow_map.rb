class FlowMap

  include Stealth::Flow

  flow :hello do
    state :say_hello
  end

  flow :goodbye do
    state :say_goodbye
  end

  flow :interrupt do
    state :say_interrupted
  end

  flow :unrecognized_message do
    state :handle_unrecognized_message
  end

  flow :catch_all do
    state :level1
  end

end
