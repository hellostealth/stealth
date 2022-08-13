# Tunnels

When developing locally, message platforms require access to the Stealth server running on your machine in order to transmit user messages.&#x20;

Here are some options you can use:

### ngrok

1. Download [ngrok](https://ngrok.com/download)
2. Start your Stealth server as detailed in [Booting Up](booting-up.md#boot-your-bot).
3. Open up an ngrok tunnel to your Stealth server and port (default 5000) like this: `ngrok http 5000`. ngrok will output a unique ngrok local tunnel URL to your machine.

When you provide your local ngrok URL to a messaging service, you will have to add `/incoming/<service>`. For example:

* `https://abc1234.ngrok.io/incoming/facebook`
* `https://abc1234.ngrok.io/incoming/twilio`

More details on service specific settings can be found on the GitHub page for each service gem.
