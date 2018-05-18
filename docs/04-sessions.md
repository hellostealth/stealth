---
title: Sessions
---

A user of your bot can be in any single flow and state at any given moment. They can never be in more than one flow or state. For this reason, Stealth sessions are modeled using [finite state machines](https://en.m.wikipedia.org/wiki/Finite-state_machine).

## Finite State Machines

Technically, each flow is its own state machine with its own states. Stealth, however, does not restrict the movement between states as rigidly. So while we find the state machine model helpful to learn sessions, don't spend too much time on Wikipedia!

## Redis Backed Sessions

User sessions are stored in Redis. Each session is a lightweight key-value pair. The key is the user's ID from the service -- so for Facebook it may be a long integer value: `100023838288224423`. The value is the flow and state for the user separated by a "stabby" operator (`->`).

So if for example a user with ID `100023838288224423` is currently at the `hello` flow and `ask_name` state, the value for the key would be: `hello->ask_name`.

You likely won't be interacting with sessions directly since Stealth manages it automatically for you. We just present it here for clarity into how sessions work.
