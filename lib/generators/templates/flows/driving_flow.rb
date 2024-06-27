Stealth.flow :driving do
  state :schedule_checkin do
    step_to_in 1.hour, state: :ask_to_continue
    update_session_to state: :say_safe_drive
  end

  state :say_safe_drive do
    send_replies
    step_to slug: current_lead.return_to_slug
  end

  state :ask_to_continue do
    if previous_session.flow_string == 'driving'
      send_replies
      update_session_to state: :get_continue_response
    else
      update_session_to session: previous_session
    end
  end

  state :get_continue_response, fails_to: :ask_to_continue, reengage: true do
    handle_message(
      :yes => proc {
        step_to slug: current_lead.return_to_slug
      },
      :no => proc {
        do_nothing
      }
    )
  end
end
