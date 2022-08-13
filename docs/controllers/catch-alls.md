# Catch-Alls

Stealth Catch-Alls are designed to handle the error cases within bots. Either the bot doesn't understand what a user typed or an error occurred. If this were a webpage, we'd see the dreaded HTTP 500 error page.&#x20;

Catch-Alls are designed to move beyond simple "I don't understand" messages and help users get back on track. The better your CatchAlls, the better your bot.

### Triggering

The `catch_all` flow is automatically triggered when either of two things happens within a controller action:

1. The action [fails to progress a user](controller-overview.md#failing-to-progress-a-user).
2. An Exception is raised.

{% hint style="info" %}
If an action within `CatchAllsController` raises an exception, it won't fire another Catch-All to prevent loops.
{% endhint %}

### Multi-Level

Stealth keeps track of how many times a Catch-All is triggered for a given session. This allows you to build experiences in which the user is provided different responses for subsequent failures.

So for example, if in the `hello` flow and `say_hello` state an exception is raised, then Catch-All _Level 1_ will be called. If the user is return to that same flow and state and another exception is raised, Catch-All _Level 2_ will be called. This continues until you either run out of Catch-All states or if the Catch-All counter resets.

{% hint style="info" %}
The Catch-All counter currently resets after 15 minutes. This is per flow and state. So a user may encounter a Catch-All elsewhere in your bot and it will utilize a separate Catch-All counter.
{% endhint %}

### Retrying

By default, a Stealth bot comes with Catch-All Level 1 already defined. Here is the default `CatchAllsController` and associated reply:

```ruby
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
```

```yaml
- reply_type: text
  text: Oops. It looks like something went wrong. Let's try that again
```

In the controller action, we check if the `previous_session` (the one that failed) specified a `fails_to` state. If so, we send the user there. Otherwise, we send the user back 2 states.

Sending a user back two states is a pretty good generic action. Going back 1 state takes us back to the action that failed. Since the actions most likely to fail are `get` actions, or actions that deal with user responses, going back 2 states usually takes us back to the original "question".

{% hint style="info" %}
Where possible, it's better to specify a `fails_to` state so Stealth doesn't incorrectly guess where to send your user back.
{% endhint %}

### Adding More Levels

If you would like to extend the experience, add a `level2` controller action and associated reply (and update the `FlowMap`). You can go as far as you want. CatchAlls have no limit, just make sure you increment using the standardized method names of `level1`, `level2`, `level3`, `level4`, etc.

If a user has encountered the maximum number of CatchAll levels that have been defined, it won't attempt to call any more levels.

{% hint style="warning" %}
For the last Catch-All state, you'll probably want to prompt the user to contact support or send them to a special menu to choose from.
{% endhint %}

### Catch-All Reasons

As mentioned in the [Triggering](catch-alls.md#triggering) section above, there are two reasons a Catch-All triggers. Stealth will provide the `CatchAllsController` with that reason so you can customize your messages and take the appropriate action.

So if for example your bot just didn't recognize the message sent by the user, you may ask the user to repeat. If however, your database is down, you might other action.

Here is an example usage:

```ruby
class CatchAllsController < BotController
  
  before_action :set_catch_all_reason

  def level1
    send_catch_all_replies('level1')

    if fail_session.present?
      step_to session: fail_session, pos: -1
    else
      step_to session: previous_session - 2.states, pos: -1
    end
  end

  def level2
    send_catch_all_replies('level2')
  end

  def level3
    send_catch_all_replies('level3')
  end

  private

  def fail_session
    previous_session.flow.current_state.fails_to
  end

  def send_catch_all_replies(level)
    if @reason == :unrecognized_message
      send_replies(custom_reply: "catch_alls/#{level}_unrecognized")
    else
      send_replies(custom_reply: "catch_alls/#{level}")
    end
  end

  def set_catch_all_reason
    @reason = case current_message.catch_all_reason[:err].to_s
    when 'Stealth::Errors::UnrecognizedMessage'
      :unrecognized_message
    else
      :system_error
    end
  end

end

```

In this `CatchAllsController` we have two sets of Catch-All replies. One for when the message was unrecognized and another for when we've encountered a system error. We dynamically send the appropriate reply based on the `@reason` instance variable that we set with the `before_action` in the controller.
