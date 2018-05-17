---
title: Local Development
---

## Prerequisites

Stealth bundles [Sidekiq](https://github.com/mperham/sidekiq) in order to process background jobs. Therefore, it is required to run Redis in order to boot up a Stealth server.

## Starting the Server

Once you have made your current working directory your Stealth bot, you can install gems:

```
bundle install
```

To boot your bot:

```
stealth server
```

You can also use `stealth s`. This will use the [foreman](https://github.com/ddollar/foreman) gem to start the web server and Sidekiq processes together. Redis will have to be running for the server to start.

That's it! You are now running Stealth.

## Introspectable Tunnels to localhost

When developing locally, messaging services require access to your server in order to transmit user messages. We recommend downloading and using [ngrok](https://ngrok.com/download) to create a local tunnel to your development machine.

1. Download [ngrok](https://ngrok.com/download)
2. Start your Stealth server as detailed above.
3. Open up an ngrok tunnel to your Stealth server and port (default 5000) like this: `ngrok http 5000`. ngrok will output a unique ngrok local tunnel URL to your machine.

When you provide your local ngrok URL to a messaging service, you will have to add `/incoming/<service>`. For example:

 * `https://abc1234.ngrok.io/incoming/facebook`
 * `https://abc1234.ngrok.io/incoming/twilio`

More details on service specific settings can be found on the GitHub page for each service gem.
