---
description: >-
  Some common terms you may read throughout this doc or as you interact with the
  Stealth community.
---

# Glossary

* **message** - An _incoming_ message from a user. A _message_ and a _reply_ are counterparts.
* **reply** - An _outgoing_ message from your bot. A _message_ and a _reply_ are counterparts.
* **service message** - This is the long version of _message_. You will likely only see this referenced when developing your own Stealth components.
* **`current_message`** - This is object that contains the service message. It's available within all controller actions. More info can be found in the [controller docs](controllers/controller-overview.md).
* **component** - Components are the individual building blocks of Stealth. Stealth itself is the core framework that handles webhooks, replies, etc. Components allow Stealth to connect to messaging platforms, NLP providers, and more. Each component is offered as a separate Ruby gem.
* **message platform** - Message platforms are the platforms where your bot interacts with its users. E.g., Facebook Messenger, SMS, Whatsapp, Slack, etc.
* **NLP** - natural language processing. This is the AI subfield that encompasses taking unstructured text (like messages from users) and extracting structured concepts. NLP in Stealth is achieved through components.
* **NLU** - A subclass of NLP. More aptly describes the type of NLP you'll want to perform with Stealth, but NLP is the more commonly used term.
* **session** - Sessions allow your Stealth bot to recognize subsequent messages from users. It keeps track of where in the conversation each of your users currently reside.
* **MVC** - A software design pattern. It's not critical to understand this to get going, but if you're interested you can learn more [here](https://www.google.com/url?sa=t\&rct=j\&q=\&esrc=s\&source=web\&cd=\&cad=rja\&uact=8\&ved=2ahUKEwiGt\_XpzPHtAhXNVc0KHWjiDG8QFjAAegQIBRAC\&url=https%3A%2F%2Fen.wikipedia.org%2Fwiki%2FModel%25E2%2580%2593view%25E2%2580%2593controller\&usg=AOvVaw1wpuCUJRz1WxG51eRibnYX).
* **intent** - **** Intents are one of the main things NLP components extract from a message. They are a type of classification. We talk about them in more detail in the `handle_message` [docs](controllers/handle\_message/nlp-matcher.md).
* **entity** - Entities are individual tokens within a message that an NLP component will extract. So for example, a number or some other trained entity specific to your bot (like car models and makes). More info about these can be found in the `get_match` [docs](controllers/get\_match/entity-match.md).
* **regex** - A regular expression. These are a programming concept used in string matching. In Stealth, these are most often used in `handle_message` and there are [docs](controllers/handle\_message/regex-matcher.md) for their usage.
