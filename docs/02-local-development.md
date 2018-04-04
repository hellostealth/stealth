---
title: Local Development with ngrok
---

When developing locally, every messaging service requires access to your server. We recommend downloading and using ngrok to create a local tunnel to your development machine. It's pretty easy.

First, download ngrok here: https://ngrok.com/download

After you download ngrok, start your Stealth server. Once Stealth is started, you can open up a public tunnel to your stealth server and port (default 3000) like this:

  ```
  ngrok http 3000
  ```

ngrok should then display a unique ngrok local tunnel URL to your machine.

When you provide your URL to the messaging service make sure to place `/incoming/<service>` after your URL. For example:

 `https://abc1234.ngrok.io/incoming/facebook`
 `https://abc1234.ngrok.io/incoming/twilio`
