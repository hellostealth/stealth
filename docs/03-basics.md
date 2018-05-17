---
title: The Basics
---

## Directory Structure

When you open up your Stealth bot you will see the following file structure:

```
├── Gemfile
├── Procfile.dev
├── README.md
├── Rakefile
├── bot
│   ├── controllers
│   │   ├── bot_controller.rb
│   │   ├── catch_alls_controller.rb
│   │   ├── concerns
│   │   ├── goodbyes_controller.rb
│   │   └── hellos_controller.rb
│   ├── helpers
│   │   └── bot_helper.rb
│   ├── models
│   │   ├── bot_record.rb
│   │   └── concerns
│   └── replies
│       ├── catch_alls
│       │   └── level1.yml
│       ├── goodbyes
│       │   └── say_goodbye.yml
│       └── hellos
│           └── say_hello.yml
├── config
│   ├── boot.rb
│   ├── database.yml
│   ├── environment.rb
│   ├── flow_map.rb
│   ├── initializers
│   ├── puma.rb
│   ├── services.yml
│   └── sidekiq.yml
├── config.ru
└── db
    └── seeds.rb
```

## Flows

A `Flow` is a general term to describe a complete interaction between a user and the bot. Flows are comprised of `states`, like a finite state machine.

For example, if a user was using your bot to receive an insurance quote, the flow might be named `quote`. Note: Stealth requires that flows be named in the singular form, like Rails.

A flow consists of the following components:

1. A controller file, named in the plural form. For example, a `quote` flow would have a corresponding `QuotesController`.
2. Replies. Each flow will have a directory in the `replies` directory in plural form. Again using the `quote` flow example, the directory would named `quotes`.
3. An entry in `config/flow_map.rb`. The `FlowMap` file is where each flow and it's respective states are defined for your bot.

Flows can be generated using a generator:

```
  stealth generate flow <NAME>
```

## FlowMap

The `FlowMap` file is where each flow and it's respective states are defined for your bot. Here is an example `flow_map.rb`:

```ruby
class FlowMap

  include Stealth::Flow

  flow :hello do
    state :say_hello
    state :ask_name
    state :get_name, fails_to: :ask_name
  end

  flow :goodbye do
    state :say_goodbye
  end

  flow :catch_all do
    state :level1
    state :level2
  end

end
```

Here we have defined three flows: `hello`, `goodbye`, and `catch_all`. For the most part, these are default flows that are generated automatically when you create a new bot but we have made a few changes to highlight some functionality.

In the `hello` flow, the second state asks a user for their name. In the third state of `hello`, you see another option: `fails_to`. This is used to tell Stealth to return the user to the specified state if the `get_name` state raises an error or fails in another way. There are more details in the `CatchAll` section below.

## Default Flows

When you generate a new Stealth bot, it comes packaged with three default flows. While you will likely add many flows of your own, we recommend keeping these three flows as they encourage good bot building practices.

## Hello & Goodbye

These two flows make up the entrance and exit of your bot. We include blank examples on how to greet (say hello) and sendoff (say goodbye) your users. You can customize these flows to work with the design of your bot.

## CatchAll

Stealth also comes packaged with a `catch_all` flow. Stealth CatchAlls are designed to handle scenarios in which the user says something the bot is not expecting or the bot encounters an error.

Error handling is one of the most important parts of building great bots. We recommend that bot designers and developers spend sufficient time building the CatchAll states.

See the Catch All (#catchalls) section for more information on how Stealth handles `catch_all` flows.

## Say, Ask, Get

Stealth recommends you use the `say`, `ask`, and `get` prefix for your flow state names. It's not required, but it is a convention we have found helpful to keep state names under control. It also helps other developers on your team follow along more easily.

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

*GET* Stealth actions are for _getting_ and parsing a response from the user.

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
