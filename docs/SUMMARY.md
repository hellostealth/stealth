# Table of contents

* [Intro](README.md)
* [Getting Started](getting-started.md)
* [Basics](basics.md)
* [Dev Environment](dev-environment/README.md)
  * [Booting Up](dev-environment/booting-up.md)
  * [Hot-Code Reloading](dev-environment/hot-code-reloading.md)
  * [Procfile](dev-environment/procfile.md)
  * [Tunnels](dev-environment/tunnels.md)
  * [Environment Variables](dev-environment/environment-variables.md)
  * [Logs](dev-environment/logs.md)
* [Glossary](glossary.md)

## Flows

* [Flows & States](flows/overview.md)
* [State Naming](flows/state-naming.md)
* [FlowMap](flows/flowmap.md)
* [State Options](flows/state-options.md)

## Controllers

* [Controller Overview](controllers/controller-overview.md)
* [Sessions](controllers/sessions/README.md)
  * [Session Overview](controllers/sessions/intro.md)
  * [step\_to](controllers/sessions/step\_to.md)
  * [step\_to\_in](controllers/sessions/step\_to\_in.md)
  * [step\_to\_at](controllers/sessions/step\_to\_at.md)
  * [update\_session\_to](controllers/sessions/update\_session\_to.md)
  * [step\_back](controllers/sessions/step\_back.md)
  * [do\_nothing](controllers/sessions/do\_nothing.md)
* [route](controllers/route.md)
* [Available Data](controllers/available-data.md)
* [handle\_message](controllers/handle\_message/README.md)
  * [String Matcher](controllers/handle\_message/string-mather.md)
  * [Alpha Ordinal Matcher](controllers/handle\_message/alpha-ordinal-matcher.md)
  * [Homophone Detection](controllers/handle\_message/homophone-detection.md)
  * [NLP Matcher](controllers/handle\_message/nlp-matcher.md)
  * [Regex Matcher](controllers/handle\_message/regex-matcher.md)
  * [Nil Matcher](controllers/handle\_message/nil-matcher.md)
* [get\_match](controllers/get\_match/README.md)
  * [Exact Match](controllers/get\_match/exact-match.md)
  * [Alpha Ordinals](controllers/get\_match/alpha-ordinals.md)
  * [Entity Match](controllers/get\_match/entity-match.md)
* [Catch-Alls](controllers/catch-alls.md)
* [Dev Jumps](controllers/dev-jumps.md)
* [Interrupt Detection](controllers/interrupt-detection.md)
* [Unrecognized Messages](controllers/unrecognized-messages.md)
* [Platform Errors](controllers/platform-errors.md)

## Replies

* [Reply Overview](replies/reply-overview.md)
* [YAML Replies](replies/yaml-replies.md)
* [ERB](replies/erb.md)
* [Delays](replies/delays.md)
* [Variants](replies/variants.md)
* [Inline Replies](replies/inline-replies.md)

## Models

* [Model Overview](models/overview.md)
* [ActiveRecord](models/activerecord.md)
* [Mongoid](models/mongoid.md)

## Platforms

* [Platform Overview](platforms/overview.md)
* [Facebook Messenger](platforms/facebook-messenger.md)
* [SMS/Whatsapp](platforms/sms-whatsapp.md)
* [Alexa Skills](platforms/alexa-skills.md)
* [Voice](platforms/voice.md)

## NLP/NLU

* [NLP Overview](nlp-nlu/overview.md)
* [Microsoft LUIS](nlp-nlu/microsoft-luis.md)
* [OpenAI](nlp-nlu/openai.md)

## Config

* [Settings](config/settings.md)
* [services.yml](config/services.yml.md)

## Testing

* [Specs](testing/untitled.md)
* [Integration Testing](testing/integration-testing.md)

## Deployment

* [Deployment Overview](deployment/overview.md)
* [Heroku](deployment/heroku.md)

## Building Components

* [Message Services](building-components/message-services.md)
* [NLP](building-components/nlp.md)
