---
title: Local Development
---
## Starting the Server

Change directory into to `mybot`. To boot this bot locally run:

`stealth server`

Using [foreman](https://github.com/ddollar/foreman) will start the web server and Sidekiq processes together.

You now have default Stealth bot ready for you to start adding functionality to.

## Introspectable Tunnels to localhost

When developing locally, every messaging service requires access to your server. We recommend downloading and using ngrok to create a local tunnel to your development machine. It's pretty easy.

First, download ngrok here: https://ngrok.com/download

After you download ngrok, start your Stealth server as detailed above. Once Stealth is started, you can open up a public tunnel to your Stealth server and port (default 5000) like this:

`ngrok http 5000`

ngrok should then display a unique ngrok local tunnel URL to your machine.

When you provide your URL to the messaging service make sure to place `/incoming/<service>` after your URL. For example:

 * `https://abc1234.ngrok.io/incoming/facebook`
 * `https://abc1234.ngrok.io/incoming/twilio`
