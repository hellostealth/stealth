---
title: Catch All
---

Stealth Catch Alls are designed to handle the most common scenario inside of a bot. What happens when the user says something the bot doesn't understand. The majority of bots will simply respond back with a generic "I don't understand" and expect the user to figure it out. While this experience might be ok for some bots, we created a more advanced way of handling these experiences. The better your Catch Alls, the better your bot.

## Triggering

Catch all flows are automatically triggered when a controller action does not successfully `update_session_to` or `step_to`. This could be when a user says something that's not handled or even a API call 500's.

## Multi Level

Stealth also keeps track of how many times the catch all is triggered. This allows you to build experiences in which the user is provided different responses for the 2nd or 3rd time.

By default a Stealth bot comes with the first level catch all. For example here is the controller action and associated reply:

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

If you would like to expand the experience simply add a `level2` controller action and associated reply. You can go as far as you want. Catch Alls have no limit just make sure you increment using the standardized method names of `level1`, `level2`, `level3`, `level4`, etc.
