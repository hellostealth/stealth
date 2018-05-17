---
title: The Basics
---

## Directory Structure

When you open up your Stealth bot you will see the following file structure:

```
├── Gemfile
├── Procfile.dev
├── README.md
├── bot
│   ├── controllers
│   │   ├── bot_controller.rb
│   │   ├── catch_alls_controller.rb
│   │   ├── goodbyes_controller.rb
│   │   └── hellos_controller.rb
│   ├── flow_map.rb
│   ├── helpers
│   │   └── bot_helper.rb
│   └── replies
│       ├── catch_alls
│       │   └── level1.yml
│       ├── goodbyes
│       │   └── say_goodbye.yml
│       └── hellos
│           └── say_hello.yml
├── config
│   ├── boot.rb
│   ├── environment.rb
│   ├── initializers
│   ├── puma.rb
│   ├── services.yml
│   └── sidekiq.yml
└── config.ru
```

## Flows

A `Flow` is a general term to describe a complete user interaction with the bot. For example, if a user was using your bot to receive an  insurance quote. This would be referred to as a `Quotes` flows.

A flow always has a controller file and associated reply files. It could also include a model file if you're interacting with data.

Flows can be generated using the following command:

```
  stealth generate flow <NAME>
```

## Default Flows

When you generate a new Stealth bot it comes packaged with a few default flows to get you started.

## Hello & Goodbye

The first ones are the `Hello` and `Goodbye` flows. These are blank examples on how to greet (say hello) and dismiss (say goodbye) your users. You are encouraged to customize these flows as you see fit.

## Catch All

Stealth also comes packaged with a multi-level `Catch All` flow. Stealth Catch Alls are designed to handle scenarios in which the user says something the bot is not expecting.

For example, let's say you *ask* the user for their 5 digit zip code and the user replies with a city name. You may not handle for city names, only numeric zip codes. The catch all flows are designed to provide a consistent experience to guide the user back on track to providing a 5 digit zip code.

It's recommend that bot designers and developers spend sufficient time strategizing around these flows.

See the Catch All (#catchalls) section for more information on how Stealth handles `Catch All` flows.

## Say, Ask, Get

Stealth recommends you follow the Say, Ask, Get prefix for both controller actions and replies.

### SAY

*SAY* Stealth actions are for _saying_ something to the user.

For example:

```ruby
  def say_hello
    send_replies
  end
```

### ASK

*ASK* Stealth actions are for _asking_ something from the user.

For example:

```ruby
  def ask_weather
    send_replies
    update_session_to state: 'get_weather_reponse'
  end
```

### GET

*GET* Stealth actions are for _getting_ and parsing the reponse from the user.

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
