class CatchAllsController < BotController

  def level1
    send_replies

    if previous_session_specifies_fails_to?
      step_to flow: previous_session.flow_string, state: previous_state.to_s
    else
      step_to session: previous_session - 2.states
    end
  end

private
   def previous_session_specifies_fails_to?
     previous_state.present?
   end

   def previous_state
     previous_session.flow.current_state.fails_to
   end

end
