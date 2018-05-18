---
title: CatchAll
---

Stealth CatchAlls are designed to handle a very common scenario within chatbots. What happens when the user says something the bot doesn't understand? The majority of bots will simply respond back with a generic "I don't understand" and hope the user to figures out the next step. While this experience might be ok for some bots, we built a more robust way of handling these experiences right into Stealth. The better your CatchAlls, the better your bot.

## Triggering

A CatchAll flow is automatically triggered when a controller action fails to do **at least one** of the following:

1. Update a session (via `step_to`, `update_session_to`, or any other of the step methods)
2. Send a reply via `send_replies`

In addition to the above two conditions, if your controller action raises an Exception, the CatchAll flow will automatically be triggered.

## Multi-Level

Stealth keeps track of how many times a CatchAll is triggered for a given session. This allows you to build experiences in which the user is provided different responses for subsequent failures. Once a session progresses past a failing state, the CatchAll counter resets.

## Retrying

By default, a Stealth bot comes with the first level CatchAll already defined. Here is the `CatchAllsController` action and associated reply:

```ruby
def level1
  send_replies

  if previous_session_specifies_fails_to?
    step_to flow: previous_session.flow_string, state: previous_state.to_s
  else
    step_to session: previous_session - 2.states
  end
end
```

```yml
- reply_type: text
  text: Oops. It looks like something went wrong. Let's try that again
```

In the controller action, we check if the `previous_session` (the one that failed) specified a `fails_to` state. If so, we send the user there. Otherwise, we send the user back 2 states.

Sending a user back two states is a pretty good generic action. Going back 1 state takes us back to the action that failed. Since the actions most likely to fail are `get` actions, or actions that deal with user responses, going back 2 states usually takes us back to the original "question".

## Adding More Levels

If you would like to expand the experience, simply add a `level2` controller action and associated reply (and update the `FlowMap`). You can go as far as you want. CatchAlls have no limit, just make sure you increment using the standardized method names of `level1`, `level2`, `level3`, `level4`, etc.

If a user has encountered the maximum number of CatchAll levels as you have defined, the user's session will remain at the last CatchAll state.
