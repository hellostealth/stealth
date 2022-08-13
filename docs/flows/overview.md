# Flows & States

## Overview

Flows and states are the principle architectural building blocks for Stealth bots. Your bot's users can only be in a single flow and state at any given moment. The relationship between flows and states is one of parent and child, respectively. So a flow can _have many_ states and a state always _belongs to_ a single flow.

The concept is modeled after [finite-state machines](https://en.m.wikipedia.org/wiki/Finite-state\_machine), though you don't need to familiarize yourself with all of that knowledge. The outline we provide in these docs will be sufficient.

Finite-state machines, or more simply state machines, are used throughout engineering to model states within a given machine. Imagine a coin-operated, turnstile you might find in a subway or airport. You insert a coin and the mechanism unlocks to allow you to rotate the arms and pass through.

![Figure 1: A simple, coin-operated turnstile](../../.gitbook/assets/torniqueterevolution.jpg)

The operation of this turnstile can (and probably is) modeled as a state machine. Here is an example of what that model looks like:

![Figure 2: Finite-state machine model for the simple, coin-operated turnstile.](../../.gitbook/assets/2880px-turnstile\_state\_machine\_colored.svg.png)

In Figure 2, the "starting" state is _Locked_ and if someone attempts to _Push_ the turnstile arms while it is in the _Locked_ state it will indefinitely remain in the _Locked_ state. That's what the self-referencing _Push_ action in Figure 2 is showing. Similarly, in Stealth, states can transition a user to a new state or it can keep a user in the same state either indefinitely or until some specific action is taken.

When a user inserts a _Coin_, the state machine in Figure 2 transitions the machine to the _Unlocked_ state. If a user inserts more coins while in this state, the machine just remains in the _Unlocked_ state. When the turnstile arms are _Pushed_, then the machine transitions back to the _Locked_ state.

This turnstile example highlights the mental model of flows and states in Stealth quite well. Specifically, states can transition your users to other states or they can keep your user in the same state. In the section about [Sessions](../controllers/sessions/), we'll cover all the ways these transitions can happen.

## Flows

A **flow** is the term used to describe a complete interaction between a user and the bot. Flows are comprised of `states`, like a finite state machine. In Figure 2 above, the entire finite-state machine is the flow.

For example, if a user is using your bot to receive an insurance quote, the flow might be named `quote`.&#x20;

{% hint style="warning" %}
Stealth requires that flows be named in the singular form, like Ruby on Rails.
{% endhint %}

A flow consists of the following components:

1. A controller file, named in the plural form. For example, a `quote` flow would have a corresponding `QuotesController`. One controller maps to one flow.
2. Replies. Each flow will have a directory in the `replies` directory in plural form. Again using the `quote` flow example, the directory would named `quotes`.
3. An entry in the `FlowMap`. The `FlowMap` file is where each flow and it's respective states are defined. We'll cover the FlowMap file in [FlowMap docs](flowmap.md) section.

## States

A **state** is the logical division of flows. Just like in finite-state machines, users can transition between states. In Stealth, users can even transition between states from different flows. There are no naming conventions enforced by Stealth for states, but in [State Naming section](state-naming.md) we'll cover some best practices.

As mentioned in the above, a user can at most be in a single flow and state at any given moment.
