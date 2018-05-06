---
title: Sessions
---

## State Machines

TODO: Need to understand more about how Stealth handles the it's session around State Machines.

## Redis Backed Sessions

TODO Need to understand how redis fits in here.

## `current_user`

The user is available to you at anytime using `current_user`.

## `current_session`

The users' session is available to you at anytime using `current_session`.

## `current_message`

The users' current message is available to you at anytime using `current_message`. Note: `current_message` is full payload back from the specific messaging service.

For example:

```
if current_message.message = "hello"
  step_to flow: 'hello', state: 'say_hello'
end  
```
