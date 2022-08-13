# State Naming

While Stealth doesn't enforce any naming requirements for your states, we do recommend following the naming conventions outlined below. It provides continuity across your team and across bots.

Most of your states will fall into the `say`, `get`, and `ask` buckets. On the rare occasion that it does not, feel free to select a name that best describes the state.

## Say, Ask, Get

#### Say

_Say_ actions are for _saying_ something to the user.

For example:

```ruby
def say_hello
  send_replies
end
```

Typically we'd send the user to a new state, but sometimes it's as simple as just saying something like in the case of the end of a flow or conversation.

#### Ask

_Ask_  actions are for _asking_ something from the user.

For example:

```ruby
def ask_weather
  send_replies
  update_session_to state: 'get_weather_response'
end
```

In the above example, we've asked a question via `send_replies` and we've updated the session to a new state. This is the state that will be receiving the response. We'll cover state transitions in detail in the [Sessions Overview](../controllers/sessions/intro.md) section.

#### Get

_Get_  actions are for _getting_ and parsing a message from the user.

For example:

```ruby
def get_weather_response
  handle_message(
    'Sunny'   => proc { step_to state: 'say_wear_sunglasses' },
    'Raining' => proc { step_to state: 'say_dont_forget_umbrella' }
  )
end
```

In the example above, we're handling two responses by the user. When they say "Sunny" or "Raining". Don't worry too much about the format of `handle_message`. We cover its usage in the [handle\_message docs](../controllers/handle\_message/) section.
