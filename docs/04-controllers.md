---
title: Controllers
---

Controllers are responsible for handling incoming requests and providing a appropriate user response (reply). Every Stealth project comes with a default `bot_controller.rb`

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

The power of three. Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.

## Stepping, Jumping and Updating Sessions

Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.

## Get, Ask, and Say

The power of three. Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.

## Callbacks

The power of three. Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.

## `handle_payloads`

The power of three. Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.
