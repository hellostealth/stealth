---
description: Tips for streamlining your environment variable management during development.
---

# Environment Variables

Environment variables (ENV Vars) will likely be an important part of your configuration. Each message platform component, NLP component, and others will likely require one or more API keys.&#x20;

Most production environments will provide a way for you to specify your production keys. But for development, we recommend using the [dotenv](https://github.com/bkeepers/dotenv) gem. This gem will allow you to specify a `.env` file in your bot repo from where you can set all of your environment variables.

{% hint style="info" %}
Stealth will automatically exclude the `.env` file from git.
{% endhint %}

### Configuring dotenv in Stealth

Add the [dotenv](https://github.com/bkeepers/dotenv) gem to your `Gemfile`:

```ruby
group :development do
  gem 'foreman'
  gem 'listen', '~> 3.3'
  gem 'dotenv'
end
```

Install the gem:

```ruby
bundle install
```

Load dotenv on boot via `boot.rb`:

```ruby
require 'stealth/base'
if %w(development test).include?(Stealth.env)
  require 'dotenv/load'
end
require_relative './environment'
```

{% hint style="info" %}
You'll be adding Lines 2-4 right below Line 1 which will already be there.
{% endhint %}

That's it! Now you can specify your environment variables via the `.env` file:

```
FACEBOOK_VERIFY_TOKEN=some_value
LUIS_APP_ID=1234
LUIS_ENDPOINT=your_endpoint.cognitiveservices.azure.com
LUIS_SUBSCRIPTION_KEY=xyz1234
```
