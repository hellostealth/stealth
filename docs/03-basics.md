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
3. An entry in `config/flow_map.rb`. The `FlowMap` file is where each flow and its respective states are defined for your bot.

Flows can be generated using a generator:

```
  stealth generate flow <NAME>
```

## FlowMap

The `FlowMap` file is where each flow and its respective states are defined for your bot. Here is an example `flow_map.rb`:

```ruby
class FlowMap

  include Stealth::Flow

  flow :hello do
    state :say_hello
    state :ask_name
    state :get_name, fails_to: :ask_name
    state :say_wow, redirects_to: :say_hello
    state :say_bye, redirects_to: 'goodbye->say_goodbye'
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

Here we have defined three flows: `hello`, `goodbye`, and `catch_all`. These are the default flows that are generated for you when you create a new bot. We have made a few changes above to highlight some functionality.

Each flow consists of an arbitrary number of states. These states should each have a corresponding controller action by the same name. States also support two additional options: `fails_to` and `redirects_to` which we explain below.

## Default Flows

When you generate a new Stealth bot, it comes packaged with three default flows. While you will likely add many flows of your own, we recommend keeping these three flows as they encourage good bot building practices.

## Hello & Goodbye

These two flows make up the entrance and exit of your bot. We include blank examples on how to greet (say hello) and sendoff (say goodbye) your users. You can customize these flows to work with the design of your bot.

## CatchAll

Stealth also comes packaged with a `catch_all` flow. Stealth CatchAlls are designed to handle scenarios in which the user says something the bot is not expecting or the bot encounters an error.

Error handling is one of the most important parts of building great bots. We recommend that bot designers and developers spend sufficient time building the CatchAll states.

See the Catch All (#catchalls) section for more information on how Stealth handles `catch_all` flows.

## fails_to

The `fails_to` option allows you to specify a state that a user should be redirected to in case of an error. The `CatchAllsController` will still be responsible for determining how to handle the error, but by specifying a `fails_to` state here, the `CatchAllsController` is able to redirect accordingly.

A freshly generated bot will contain sample `CatchAll` code for redirecting a user to a `fails_to` state.

The `fails_to` option takes a state name (string or symbol) or a session key. See [Redis Backed Sessions](#sessions.redis_backed_sessions) (or in the FlowMap example above) for more info about session keys. By specifying a session key, you can fail to a completely different flow from the one where the error occurred.

## redirects_to

The `redirects_to` option allows you specify a state that a user should be redirected to. This is useful if you have deprecated a state where existing users may still have open sessions pointing to the state. When a user returns to your bot, they will be redirected to the flow and state specified by this option.

Like `fails_to` above, the `redirects_to` option takes a state name (string or symbol) or a session key. See [Redis Backed Sessions](#sessions.redis_backed_sessions) (or in the FlowMap example above) for more info about session keys. By specifying a session key, you can fail to a completely different flow from the one where the error occurred.

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
