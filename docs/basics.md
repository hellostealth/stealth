---
description: A quick primer of the various pieces that comprise Stealth.
---

# Basics

## Anatomy of a Stealth Bot

A Stealth bot has two primary processes: a _web server_, and a _background job processer_. If the messaging platform being used supports it, Stealth will push a message to a queue where a reply will be constructured by a background job. This allows you to easily scale your Stealth bot across many threads and processes.

### Data Store

Stealth requires Redis. Redis is used for [session storage](controllers/sessions/intro.md) as well as the queue for background jobs. You can access the Redis store yourself via the global variable: `$redis`. You can use it as your primary data store if you are building a simple bot, but you'll likely want to use a SQL or NoSQL database for more complex bots.

### Environments

Stealth bots can be booted into three environment types: `development`, `testing`, `production`. By default, if an environment is not specified via the `STEALTH_ENV` environment variable, the `development` environment will be used. The `testing` environment is automatically used when running your specs.

### ActiveSupport

Stealth automatically includes [active\_support](https://guides.rubyonrails.org/active\_support\_core\_extensions.html). So if you're used to using certain core extensions in Ruby on Rails, you can continue to use them in your Stealth bots!

## Lifecycle of a Message

This is just a brief outline of the lifecycle of a message to help you understand how Stealth processes messages. For more detailed information that you can use to build your own message platform components, check out [those docs](building-components/message-services.md).

1. A message is received by the web server.
2. If the message platform supports it, the message is backgrounded to be processed by a background job. If the message platform does not support it ([Alexa Skill](platforms/alexa-skills.md) or [Voice](platforms/voice.md)), the message is processed inline by the web server process.
3. Stealth uses the respective message platform component to normalize the message into a standard format.
4. Stealth calls the [route](controllers/route.md) method in `BotController`. If a session exists for the user, they are routed to their current state. If a session does not exist, by default the `route` method will route the user to the `HellosController#say_hello` method.
5. The controller action will either do nothing, step to another state, update the session, or generate a reply. In the latter case, the reply will be delivered via the message platform component.

## Directory Structure

When you use the generator `stealth new` to instantiate a new bot, here is the directory structure that will be created:

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
│   │   ├── hellos_controller.rb
│   │   ├── interrupts_controller.rb
│   │   └── unrecognized_messages_controller.rb
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
│   │   ├── autoload.rb
│   │   └── inflections.rb
│   ├── puma.rb
│   ├── services.yml
│   └── sidekiq.yml
├── config.ru
└── db
    └── seeds.rb
```
