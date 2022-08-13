# Controller Overview

Controllers are responsible for handling incoming requests and getting a response back to the user via replies. They also perform all state transitions.

## Naming Conventions

The controller's methods, also referred to as actions, must be named after the flow's states. So for example, given the flow:

```ruby
flow :onboard do
  state :say_welcome
  state :ask_for_phone
  state :get_phone, fails_to: :ask_for_phone
end
```

The corresponding controller would be:

```ruby
class OnboardsController < BotController
  def say_welcome

  end

  def ask_for_phone
  
  end

  def get_phone

  end
end
```

## BotController

Every Stealth bot comes with a default `bot_controller.rb`. You don't have to know what each method does yet, we'll cover each in their respective doc sections.

```ruby
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
  # the platform. You can write your own steps for handling.
  def handle_opt_out
    do_nothing
  end

  # Automatically called when clients receive an invalid session_id error from
  # the platform. For example, attempting to text a landline.
  # You can write your own steps for handling.
  def handle_invalid_session_id
    do_nothing
  end

end

```

All of your controllers will inherit from this `BotController`:

```ruby
class QuotesController < BotController

end
```

## Failing to Progress a User

One of the primary responsibilities of a controller is to update a user's session. The other responsibility is sending replies to a user. If you fail to do either of these things, essentially the user at the other end won't have any feedback.

If a controller action fails to update the state or send any replies, Stealth will automatically fire a [CatchAll](catch-alls.md). This is designed to catch errors during development. If you are certain you don't want to send any feedback to the user for a specific action you can call [do\_nothing](sessions/do\_nothing.md) to override Stealth's default behavior. &#x20;

## Before/After/Around Filters

Like Ruby on Rails controllers, Stealth controllers support `before_action`, `after_action`, and `around_action` filters.

Given a `BotController` that loads a user:

```ruby
class BotController < Stealth::Controller

  before_action :current_user
  
  private def current_user
    @current_user ||= User.find_by_session_id(current_session_id)
  end
  
end
```

The `current_user` method will be run on all controllers that inherit from `BotController`. Similarly, if you add a `before_action` to a child controller, only that controller's actions will run that filter.
