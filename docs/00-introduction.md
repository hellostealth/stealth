---
title: Introduction
---
Stealth includes everything you need to build amazing chatbots with tools you know and love.

## Assumptions

These docs are designed for intermediate Ruby developers who want to get started with the Stealth framework.

Stealth bot framework running on the Ruby programming language. If you have no prior experience with Ruby, you might find it hard to jump into Stealth. We would recommend checking out these guides:

- [Official Ruby website](https://www.ruby-lang.org/en/documentation/)
- [List of Free Programming Books](https://github.com/EbookFoundation/free-programming-books/blob/master/free-programming-books.md#ruby)

## What is Stealth?

Stealth is an open source Ruby framework for conversational voice and text chatbots.

Stealth is inspired by the Model-View-Controller (MVC) pattern. However, instead of calling them *Views* Stealth refers to them as *Replies* to better match the chatbot domain.

- The [Model](#models) layer represents your data model (such as Account, User, Quote, etc.) and encapsulates the business logic that is specific to your bot. By default, Stealth uses [ActiveRecord](#models.active_record).

- The [Controller](#controllers) layer is responsible for handling incoming requests from messaging platforms and providing and transmitting the response (reply).

- The [Reply](#replies) layer is composed of "templates" that are responsible for constructing the respective response.

In addition to being inspired by Model-View-Controller (MVC) pattern, Stealth as a few other awesome things built in for you.

- **Plug and play services.** Every service integration in Stealth is a Ruby gem. One bot can support [multiple chat services](#messaging_integrations) (i.e. Facebook Messenger, SMS, Alexa, and more) and multiple NLP/NLU services.

- **Advanced tooling.** From web servers to continuous integration testing, Stealth is built to take advantage of all the great work done by the web development community.

- **Hosting you know.** Stealth is a Rack application. That means your bots can be [deployed](#deployment) using familiar services like Docker and Heroku.

- **Ready for production.** Stealth already powers bots for large, well-known brands including: Humana, TradeStation, Haven Life, and BarkBox.

- **Open source.** Stealth is MIT licensed to ensure you own your bot. More importantly, we welcome contributors to help make Stealth even better.
