class CatchAllsController < BotController

  def level1
    send_replies

    if fail_session.present?
      step_to session: fail_session
    else
      step_to session: previous_session - 2.states
    end
  end

private

   def fail_session
     previous_session.flow.current_state.fails_to
   end

end
