Stealth.flow :catch_all do
  before_state :set_catch_all_reason

  state :level1, reengage: false do
    say "Uh oh, let's try that again!"
  end

  state :level2, reengage: false do
    send_replies
  end

  state :level3, reenage: false do
    send_replies
  end
end
