---
title: Controllers
---

Controllers are responsible for handling incoming requests and getting a response back to the user (replies).

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

## `bot_controller.rb`

Every Stealth project comes with a default `bot_controller.rb`:

```ruby
class BotController < Stealth::Controller

  before_action :current_user

  def route
    if current_session.present?
      step_to session: current_session
    else
      step_to flow: 'hello', state: 'say_hello'
    end
  end

end
```

All of your controllers will inherit from `BotController`:

```ruby
class QuotesController < BotController

end
```

## Route Method

You can implement any method in `BotController`. Typically you will implement methods like `current_user` and methods for handling message payloads. The one method that `BotController` **must** implement is the `route` method.

The `route` method is called for every incoming message. In its default implementation, the `route` method checks whether the user already has a session, and if so routes them to that controller and action. If the user does not yet have a session, it will route them to the `hello` flow and `say_hello` action.

## Stepping and Updating Sessions

Stealth provides a few built-in methods to help you route a user through your bot.

## `step_to`

The `step_to` method is used to update the session and immediately move the user to the specified flow and/or state. `step_to` can accept a *flow*, a *state*, or both. `step_to` is often used after a `say` action where the next action typically doesn't require user input.

Some examples of the different parameters:

`step_to flow: 'hello'` - Sets the session's flow to `hello` and the state will be set to the *first* state in that flow (as defined by the `flow_map.rb` file). The corresponding controller action in the `HellosController` would also be called.

`step_to state: 'say_hello'` - Sets the session's state to `say_hello` and keeps the flow the same. The `say_hello` controller action would also be called.

`step_to flow: 'hello', state: 'say_hello'` - Sets the session's flow to `hello` and the state to `say_hello`. The `say_hello` controller action of the `HellosController` controller would also be called.

## `update_session_to`

Similar to `step_to`, `update_session_to` is used to update the user's session to a flow and/or state. It accepts the same parameters. However, `update_session_to` does not immediately call the respective controller action. `update_session_to` is typically used after an `ask` action where the next action is waiting for user input. So by asking a user for input, then updating the session, it ensures the response the user sends back can be handled by the `get` action.

Some examples of the different parameters:

`update_session_to flow: 'quote'` - Sets the session's flow to `quote` and the state will be set to the *first* state in that flow (as defined by the `flow_map.rb` file).

`update_session_to state: 'ask_zip_code'` - Sets the session's state to `ask_zip_code` and keeps the flow the same.

`step_to flow: 'quote', state: 'ask_zip_code'` - Sets the session's flow to `quote` and the state to `ask_zip_code`.

## `send_replies`

`send_replies` will instruct the `Reply` to construct the reply and transmit them. Not all of your controller actions will send replies. Typically in `get` action, you'll get a user's response, perform some action, and then send a user to a new state without replying.

The `send_replies` method does not take any parameters:

```ruby
class ContactsController < BotController
  def say_contact_us
    send_replies
  end
end
```

This would render the reply contained in `replies/contacts/say_contact_us.yml`.

## `step_to_in`

The `step_to_in` method is similar to `step_to`. The only difference is that instead of calling the respective controller action immediately, it calls it after a specified duration. It can also take a flow, state, or both.

For example:

```ruby
step_to_in 8.hours, flow: 'hello', state: 'say_hello'
```

This will set the user's session to the `hello` flow and `say_hello` state in 8 hours after being called. It will then immediately call that responsible controller action.

## `step_to_at`

The `step_to_at` method is similar to `step_to`. The only difference is that instead of calling the respective controller action immediately, it calls it at a specific date and time. It can also take a flow, state, or both.

For example:

```ruby
step_to_at DateTime.strptime("01/23/23 20:23", "%m/%d/%y %H:%M"), flow: 'hello', state: 'say_hello'
```

This will set the user's session to the `hello` flow and `say_hello` state on `Jan 23, 2023 @ 20:23`. It will then immediately call that responsible controller action.

## Available Data

Within each controller action, you have access to a few objects containing information about the session and the message the being processed.

### current_session

The user's session is available to you at anytime using `current_session`. This is a `Stealth::Session` object. It has a few notable methods:

`flow_string`: Returns the name of the flow.
`state_string`: Returns the name of the state.
`current_session + 2.states`: Returns a new session object 2 states after the current state. If we've passed the last state, the last state is returned.
`current_session - 2.states`: Returns a new session object 2 states before the current state. If we've passed the first state, the first state is returned.

### current_message

The current message being processed is available to you at anytime using `current_message`. This is a `Stealth::ServiceMessage` object. It has a few notable methods:

`sender_id`: The ID of the user sending the message. This will vary based on the service integration.
`timestamp`: Ruby `DateTime` object of when the message was transmitted.
`service`: String indicating the service from where the message originated (i.e., 'facebook').
`messsage`: String of the message contents.
`payload`: This will vary by service integration.
`location`: This will vary by service integration.
`attachments`: This will vary by service integration.
`referral`: This will vary by service integration.

### current_service

This will be a string indicating the service from where the message originated (i.e., 'facebook' or 'twilio')

### has_location?

Returns `true` or `false` depending on whether or not the `current_message` contains location data.

### has_attachments?

Returns `true` or `false` depending on whether or not the `current_message` contains attachments.

### current_session_id (previously current_user_id)

A convenience method for accessing the session's ID.
