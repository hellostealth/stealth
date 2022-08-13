---
description: Steps for booting up your bot.
---

# Booting Up

While you can use Docker or anything else to boot up your bot, there is a built-in command that utilizes [foreman](https://github.com/ddollar/foreman) to ensure your _web server_ and your _background job processor_ both boot up. If you boot only the web server bot the the background job processor, your bot will receive message but will fail to reply.

For more info about the different process types, check out [Anatomy of a Stealth bot](../basics.md#anatomy-of-a-stealth-bot).

### Install Gems

```
bundle install
```

### Boot Your Bot

```
stealth s
```

Or for the full command:

```
stealth server
```

### Tunnels to Localhost

After you boot your server, you'll likely want to use a service to create a tunnel to your localhost. This allows message platform like Facebook Messenger and Whatsapp to deliver messages to your laptop.

Check out the [docs for creating your own tunnel](tunnels.md).
