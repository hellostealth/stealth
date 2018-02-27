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
│       │   ...
│   
└───config
│    │   file021.txt
│    │   file022.txt
└───spec
│    │   file021.txt
│    │   file022.txt
```

## Flows

A `Flow` is a general term to describe a complete user interaction. For example, if a user was using your bot to retrieve a insurance quote. This could be referred to as a `Quotes Flow`.

A flow always has a controller file and it's associated reply files. It could also include a model file as well.

## Default Flows

When you generate a new Stealth bot it comes packaged with a few default flows to get you started.

## Hello & Goodbye

The first ones are the `Hello` and `Goodbye` flows.

## Catch All

TODO: Need to figure out how to explain this.
