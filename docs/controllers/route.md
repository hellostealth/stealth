---
description: Describes the route method in BotController.
---

# route

The `route` method in `BotController` is the primary entry point for messages into your bot. This method is left open for you to edit in order for you to customize that process. Here is the method after having been generated:

```ruby
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
```

The method, by default, performs three tasks:

1. Handles payloads.
2. Handles [Dev Jumps](dev-jumps.md).
3. Routes a user to their existing location based on their session or starts a new session if one does not already exist.

We'll cover 1 and 3 in more detail below. You can learn more about Dev Jumps via the [Dev Jumps docs](dev-jumps.md).

### Payloads

Payloads are used to handle things like buttons in Facebook Messenger. On other platforms, like SMS and Whatsapp, payloads might be global keywords your bot is configured to support.

Payloads have to be handled globally because a button may be tapped (or keyword typed in) at any point during a conversation. Your bot, therefore, needs to be able to handle these in any flow and state.

Line 2 in the code sample above checks if the payload field of a message is present, and if so, calls the `handle_payloads` method. Here is that method:

```ruby
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
```

By setting the payload value of a Facebook Messenger button to `developer_restart`, for example, you can trigger the conversation to restart.

{% hint style="info" %}
More information for handling global SMS or Whatsapp keywords and button payloads can be found in the respective documentation for each message platform component.
{% endhint %}

### Routing Based on Session

In the first code sample, Lines 16-20 handle routing a user to their existing session or starting a new one. For users with an existing session, you'll likely want to keep that code the same. For users without session, you may want to customize the starting flow.
