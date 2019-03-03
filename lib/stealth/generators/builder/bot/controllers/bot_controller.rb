class BotController < Stealth::Controller

  helper :all

  def route
    if current_message.payload.present?
      handle_payloads
      # Clear out the payload to prevent duplicate handling
      current_message.payload = nil
      return
    end

    if current_session.present?
      step_to session: current_session
    else
      step_to flow: 'hello', state: 'say_hello'
    end
  end

  private

  # Handle payloads globally since payload buttons remain in the chat
  # and we cannot guess in which states they will be tapped.
  def handle_payloads
    case current_message.payload
    when 'developer_restart', 'new_user'
      step_to flow: 'hello', state: 'say_hello'
    when 'goodbye'
      step_to flow: 'goodbye'
    end
  end

end
