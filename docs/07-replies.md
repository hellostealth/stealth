---
title: Replies
---

Stealth replies are used to send one or many *reply types* back to the user. Reply types are dependent on the specific messaging service you're using. Each messaging integration will detail it's supported reply types in it's respective docs.

However, here is a generic reply using text, delays, and suggestions.

```yml
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
