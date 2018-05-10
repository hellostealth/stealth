class BotController < Stealth::Controller

  helper :all

  def route
    if current_session.present?
      step_to session: current_session
    else
      step_to flow: 'hello', state: 'say_hello'
    end
  end

end
