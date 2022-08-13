# Session Overview

Sessions in Stealth allow your bot to maintain a state for each user. If you come from the web development world, they are very similar to HTTP sessions. If you don't come from that world, no worries, we'll explain how sessions work without needing to know. If you haven't yet read the primer on [Flows and States](../../flows/overview.md), we recommend you do that first.&#x20;

### How are sessions stored?

Sessions in Stealth are backed by Redis. Each user interacting with your bot has a unique ID assigned by the messaging platform that identifies them. With Facebook Messenger, it's a page-scoped ID (PSID). With SMS and Whatsapp it's a phone number. These unique IDs are used as the key in Redis.

Regardless of what it is, it allows Stealth to find and load a user's session each time a message is received.

#### Session Slugs

With the unique messaging platform ID used as the Redis key, the value is the session slug. This is a canonical string that represents a user's current flow and state. A session slug looks like this: `flow->state`. So if a user's session is currently pointing to the `hello` flow and the `say_hola` state, then the slug would be `hello->say_hola`.

{% hint style="info" %}
If a user has not interacted with your bot before, the key will therefore be `nil` indicating there is no session for the user.
{% endhint %}

#### Session Expiration

By default, sessions do not expire. This is however configurable as a [setting](../../config/settings.md).

{% hint style="warning" %}
If your bot sends re-engagements, make sure your session's expiration is set to be _after_ the last re-engagement message is sent.
{% endhint %}

#### Previous Session

In addition to storing a user's current session, Stealth also automatically maintains a copy of the previous session. This allows you to send a user "back" from a catch-all scenario.

{% hint style="info" %}
Previous sessions also expire at the same time as primary sessions.
{% endhint %}

#### State Transitions

State transitions are performed via [step\_to](step\_to.md), [step\_to\_in](step\_to\_in.md), [step\_to\_at](step\_to\_at.md), [step\_back](step\_back.md), and [update\_session\_to](update\_session\_to.md). You can also manually manipulate the key in Redis, but these are currently the only ways to alter a user's session via Stealth.
