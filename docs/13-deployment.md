---
title: Deployment
---

Stealth is a rack based application. That means it can be hosted on most platforms as well as taking advantage of existing tools such as Docker.

## Deploying on Heroku

Stealth supports [Heroku](http://herokuapp.com) out of the box. In fact, running a `stealth s` command locally boots `foreman` using a `Procfile.dev` file similar to what Heroku does. Here is a quick guide to get you started.

If you haven't, make sure to track your bot in Git

  ```
  $ git init
  Initialized empty Git repository in .git/
  $ git add .
  $ git commit -m "My first commit"
  Created initial commit 5df2d09: My first commit
   42 files changed, 470 insertions(+)
    create mode 100644 Gemfile
    create mode 100644 Gemfile.lock
    create mode 100644 Procfile
  ...
  ```

After you have your bot tracked with Git, you're ready to deploy to Heroku. Next, we'll add our bot to Heroku using:

```
$ heroku apps:create <BOT NAME>
```

You will want a production `Procfile` separate from your development `Procfile.dev`. We recommend adding:

```
web: bundle exec puma -C config/puma.rb
sidekiq: bundle exec sidekiq -C config/sidekiq.yml -q webhooks -q default -r ./config/boot.rb
release: bundle exec rake db:migrate
```

Then deploy your bot to Heroku.

```
$ git push heroku master
```

Once deployed:

1. Make sure to enable both the `Heroku Postgres` (if you use a database) and `Heroku Redis` addons
2. Make sure the `web` and `sidekiq` dynos are spun up
3. Make sure you run any `stealth setup` commands to configure your messaging service
