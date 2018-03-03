class BotController < Stealth::Controller

  def route
    if current_session.present?
      step_to session: current_session
    else
      step_to flow: 'Hello', state: 'hello'
    end
  end

end
