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

A `Flow` is a general term to describe a complete user interaction with the bot. For example, if a user was using your bot to retrieve a insurance quote. This would be referred to as a `Quotes` flows.

A flow always has a controller file and it's associated reply files. It could also include a model file if you're interacting with data.

## Default Flows

When you generate a new Stealth bot it comes packaged with a few default flows to get you started.

## Hello & Goodbye

The first ones are the `Hello` and `Goodbye` flows. These are blank examples on how to greet (say hello) and dismiss (say goodbye) your users. You are encouraged to customize these flows as you see fit.

## Catch All

Stealth also comes packaged with a multi-level `Catch All` flow. Stealth Catch Alls are designed to handle scenarios in which the user says something the bot is not expecting.

For example, let's say you *ask* the user for their 5 digit zip code and the user replies with a city name. You may not handle for city names, only numeric zip codes. The catch all flows are designed to provide an consistent experience to guide the user back on track to providing a 5 digit zip codes.

It's recommend that bot designers and developers spend sufficient time strategizing around these flows.

See the Catch All (#catchalls) section for more information on how Stealth handles `Catch All` flows.
