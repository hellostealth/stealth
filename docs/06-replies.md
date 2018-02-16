---
title: Replies
---

Welcome to our Views.

```
- reply_type: text
  text: "Hello. Welcome to our Bot."
- reply_type: delay
  duration: 2
- reply_type: text
  text: "We're here to help you learn more about something or another."
- reply_type: delay
  duration: 2
- reply_type: text
  text: 'By using the "Yes" and "No" buttons below, are you interested in do you want to continue?'
  suggestions:
    - text: "Yes"
    - text: "No"
```

## Variants

Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.

#### `send_replies`

Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.

```
def say_contact_us
  send_replies
end
```

The power of three. Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.
