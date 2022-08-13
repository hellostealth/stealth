---
description: Examining the contents of the Procfile
---

# Procfile

If you used the generator to instantiate your bot, you'll find a `Procfile.dev` in the root directory of your bot. Here are the contents:

```
web: bundle exec puma -C config/puma.rb
sidekiq: bundle exec sidekiq -C config/sidekiq.yml -q stealth_webhooks -q stealth_replies -r ./config/boot.rb
```

If you're not familiar with Procfiles, each line specifies a process name and command for the process. So in this default Procfile, we've specified 2 processes, `web` and `sidekiq`.

### Sidekiq

Currently, Stealth uses Sidekiq for processing background jobs. It is configured to monitor 2 queues by default: `stealth_webhooks` and `stealth_replies`. You can specify additional queues as needed by your bot by adding `-q <queue_name>` to the `sidekiq` Procfile entry.

{% hint style="success" %}
You can even use Sidekiq Pro and Sidekiq Enterprise if you have a license
{% endhint %}
