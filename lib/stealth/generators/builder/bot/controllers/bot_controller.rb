# frozen_string_literal: true

class BotController < Stealth::Controller

  helper :all

  def route
    if current_message.payload.present?
      handle_payloads
      # Clear out the payload to prevent duplicate handling
      current_message.payload = nil
      return
    end

    # Allow devs to jump around flows and states by typing:
    #   /flow_name/state_name or
    #   /flow_name (jumps to first state) or
    #   //state_name (jumps to state in current flow)
    # (only works for bots in development)
    return if dev_jump_detected?

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

  # Automatically called when clients receive an opt-out error from
  # the platform. You may write your own steps for handling.
  def handle_opt_out
    do_nothing
  end

  # Automatically called when clients receive an invalid session_id error from
  # the platform. For example, attempting to text a landline.
  # You may write your own steps for handling.
  def handle_invalid_session_id
    do_nothing
  end

  # Automatically called when a transmitted message is filtered/marked as spam.
  # You may write your own steps for handling.
  def handle_message_filtered
    do_nothing
  end

  # Automatically called when an unknown error is returned by the platform.
  # You may write your own steps for handling.
  def handle_unknown_error
    do_nothing
  end

end
