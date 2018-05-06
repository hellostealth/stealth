---
title: Controllers
---

Controllers are responsible for handling incoming requests and providing a appropriate response back to the user (replies). Every Stealth project comes with a default `bot_controller.rb`

## `bot_controller.rb`

```ruby
class BotController < Stealth::Controller

  before_action :current_user

  def route
    if current_message.payload.present?
      handle_payloads
      current_message.payload = nil
      return
    end

    if current_session.present?
      step_to session: current_session
    else
      step_to flow: 'hello', state: 'say_hello'
    end
  end

end
```


## Stepping and Updating Sessions

Stealth provides a few built in methods to help you navigate a user through you bot.

## `step_to`

The `step_to` is used to move the user to another flow and/or state. `step_to` can accept either a *flow* or a *state*, or both. For example:

`step_to flow: 'hello'` - This would redirect the user to the `hello` flow and start the *first* state in that flow as defined by the `flow_map.rb` file

`step_to state: 'say_hello'` - This would redirect the user to the `say_hello` state inside the current flow.

`step_to flow: 'hello', state: 'say_hello'` - This would redirect the user to the `hello` flow and start the `say_hello` state.

## `update_session_to`

Similar to `step_to`, `update_session_to` is used to update the user's session to a current flow and/or state. It accepts the same parameters.

`update_session_to flow: 'quote'` - This would update the users session to the `quote` flow and use the *first* state in that flow as defined by the `flow_map.rb` file

`update_session_to state: 'ask_zip_code'` - This would update the users session to the `ask_zip_code` state inside the current flow.

`step_to flow: 'quote', state: 'ask_zip_code'` - This would update the users session to `quote` flow and the `ask_zip_code` state.

## `send_replies`

`send_replies` is used to trigger the associated reply files. For example:

```ruby
def say_contact_us
  send_replies
end
```
