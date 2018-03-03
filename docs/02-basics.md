---
title: The Basics
---

## Directory Structure

When you open up your Stealth bot you will see the following file structure:

```
mybot
│   README.md
│   gemfile
│   config.ru    
│
└───bot
│   └───controllers
│       │   bot_controller.rb
│       │   hellos_controller.rb
│       │   goodbyes_controller.rb
│       │   ...
│   └───extensions
│       │   ...
│   └───helpers
│       │   ...
│   └───models
│       │   ...
│   └───replies
│       │   hellos
|   │   └───replies
|   │       │   hellos
│   
└───config
│    │   file021.txt
│    │   file022.txt
└───spec
│    │   file021.txt
│    │   file022.txt
```

## Flows

A `Flow` is a general term to describe a complete user interaction. For example, if a user was using your bot to retrieve a insurance quote. This could be referred to as a `Quotes` flows.

A flow always has a controller file and it's associated reply files. It could also include a model file if you're interacting with data.

## Default Flows

When you generate a new Stealth bot it comes packaged with a few default flows to get you started.

## Hello & Goodbye

The first ones are the `Hell` and `Goodbye` flows. Think of these as blank examples on how to greet and dismiss your users.

## Catch All

Stealth also comes packaged with a multi-level `Catch All` flow. See the Catch All section for more information on how Stealth handles `Catch All` flows.
