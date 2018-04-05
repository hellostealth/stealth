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


## Stepping, Jumping and Updating Sessions

Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.


## `send_replies`

Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.

```ruby
def say_contact_us
  send_replies
end
```

## Say, Ask, Get

### SAY

*SAY* Stealth Actions are for _saying_ something to the user.

For example:

```ruby
  def say_hello
    send_replies
  end
```

### ASK

*ASK* Stealth Actions are for _asking_ something from the user.

For example:

```ruby
  def ask_weather
    send_replies
    update_session_to state: 'get_weather_reponse'
  end
```

### GET

*GET* Stealth Actions are for _getting_ and parsing the reponse from the user.

For example:

```ruby
  def get_weather_reponse
    if current_message.message == 'Sunny'
      step_to state: "say_wear_sunglasses"
    elsif current_message.message == 'Raining'
      step_to state: "say_dont_forget_umbrella"
    end
  end
```

## Callbacks

The power of three. Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.

## `handle_payloads`

The power of three. Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.
