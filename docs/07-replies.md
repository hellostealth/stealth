---
title: Replies
---

Stealth replies can send one or more replies to a user. The supported reply types will depend on the specific messaging service you're using. Each service integration will detail it's supported reply types in it's respective docs.

However, here is a generic reply using text, delays, and suggestions.

```yml
- reply_type: text
  text: "Hello. Welcome to our Bot."
- reply_type: delay
  duration: 2
- reply_type: text
  text: "We're here to help you learn more about something or another."
- reply_type: delay
  duration: 2
- reply_type: text
  text: 'By using the "Yes" and "No" buttons below, are you interested in do you want to continue?'
  suggestions:
    - text: "Yes"
    - text: "No"
```

## Reply Variants

By default, Stealth will look for your replies in the folder corresponding to your controller name. So, for example, if you have a `MessagesController`, Stealth will look for replies in `bot/replies/messages`.

If you have an action named `say_hello`, it will look for a reply file named `bot/replies/messages/say_hello.yml.erb` first, and then if that is not found, it will look for `bot/replies/messages/say_hello.yml`. If neither of these files are found, Stealth will raise a `Stealth::Errors::ReplyNotFound`.

In addition to these two naming conventions, Stealth 1.1+ supports Reply Variants. By adding the name of the service to your reply filename, Stealth will reply to users from that service using the designated reply file. That's a mouthful. Let's try an example.

For example, if the bot is replying to a message via an action called `hello`:

Facebook users would receive the reply in `hello.yml+facebook.erb`.
Twilio SMS users would receive the reply in `hello.yml+twilio.erb`.
Every other service would receive the reply in `hello.yml.erb`.

This allows you to take advantage of things like Facebook Messenger Cards while still maintaining compatibility for users using SMS.

## Format

Stealth reply templates are written in YAML. Stealth doesn't use advanced YAML features, but we do recommend you familiarize yourself with the syntax. In the above reply example, you should be able to see there are 5 replies included in the reply file.

**Caveat:** YAML interprets "yes", "no", "true", "false", "y", "n", etc (without quotes) as boolean values. So make sure you wrap them in quotes as we did above.

## ERB

Reply templates currently support ERB:

```erb
- reply_type: text
  text: "Hello, <%= current_user.first_name %>. Welcome to our Bot."
- reply_type: delay
  duration: 2
- reply_type: text
  text: "We're here to help you learn more about something or another."
- reply_type: delay
  duration: 2
<% if current_user.valid? %>
  - reply_type: text
    text: 'By using the "Yes" and "No" buttons below, are you interested in do you want to continue?'
    suggestions:
      - text: "Yes"
      - text: "No"
<% end %>
```

With ERB in your reply templates, you can access controller instance variables and helper methods in your replies.

## Delays

Delays are a common pattern of chatbot design. After a block of text, it's recommended to pause for a bit to give the user a chance to read the message. The duration of the delay depends on the length of the message sent.

Stealth will pause for the duration specified. For service integrations that support it (like Facebook), Stealth will send a typing indicator while it is paused.

### Dynamic Delays

Rather than specifying an explicit delay duration, you can optionally choose to specify a dynamic duration:

```yaml
- reply_type: delay
  duration: dynamic
```

The dynamic delay uses a heuristic to dynamically determine the length of the delay. The previous message sent to the user is examined and depending on it's type and text length (in the case of text replies), an optimal duration is computed.

If you find that the dynamic delays are too fast for your taste, you can slow them down by setting the multiplier value to something between 0 and 1:

```ruby
Stealth.config.dynamic_delay_muliplier = 0.5
```

If you find them to be too slow, you can speed them up by setting the multipler to a value greater than 1:

```ruby
Stealth.config.dynamic_delay_muliplier = 2.5
```

You can set this option by setting the above value in an intializer file, i.e., `config/dynamic_delay_config.rb`.

### Randomized Text

If you wish to have your bot cycle through an Array of available text replies, you can specify the text value as an Array. This works for `text` and `speech` replies.

Here's what a sample `text` reply utilizing randomized replies would look like:

```yml
- reply_type: text
  text:
    - Welcome!
    - Bienvenido!
    - Bem vindo!
    - Benvenuto!
```

## Naming Conventions

Replies are named after a flow's state (which is also the controller's action). So for a given controller:

```ruby
class QuotesController < BotController
  def say_price

  end
end
```

You would need to place your reply template in `replies/quotes/say_price.yml`. If your template contains ERB, you must add the `.erb` suffix to the template filename: `replies/quotes/say_price.yml.erb`.
