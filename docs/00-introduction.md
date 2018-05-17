---
title: Introduction
---
Stealth includes everything you need to quickly create powerful, text and voice chatbots in Ruby.

Stealth is inspired by the Model-View-Controller (MVC) pattern. However, instead of calling them *Views* Stealth refers to them as *Replies* to better match the chatbot domain.

The [Model](#models) layer represents your data model (such as Account, User, Quote, etc.) and encapsulates the business logic that is specific to your bot. By default, Stealth uses [ActiveRecord](#models.active_record).

The [Controller](#controllers) layer is responsible for handling incoming requests from messaging platforms and providing and transmitting the response (reply).

The [Reply](#replies) layer is composed of "templates" that are responsible for constructing the respective response.
