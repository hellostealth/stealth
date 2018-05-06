---
title: Deployment
---

Stealth is a rack based web app. Which means it can be hosted on virtually anything. Virtual or Physical servers. Internally, our choice is Heroku. Check out the following for a step to step guide on deploying your Stealth bot to Heroku.

## Heroku

Since Stealth is a Ruby based Rack app, it supports deploying to [Heroku](http://herokuapp.com) out of the box.

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
