---
title: Introduction
---
Stealth includes everything you need to quickly create powerful Text and Voice bots in Ruby.

Stealth is inspired by the Model-View-Controller (MVC) pattern. However, rather than *Views* Stealth uses *Replies*. Model-Reply-Controller (MRC).

The [Model](#models) layer represents your domain model (such as Account, User, Quote, etc.) and encapsulates the business logic that is specific to your bot. Stealth uses [ActiveRecord](#models.active_record)

The [Controller](#controllers) layer is responsible for handling incoming requests and providing a appropriate user response (reply).

The [Reply](#replies) layer is composed of "templates" that are responsible for providing appropriate replies back to the user.
