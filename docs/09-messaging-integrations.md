---
title: Messaging Integrations
---

Stealth is designed for your bot to support one or more messaging integrations. For example, this could be just SMS or both SMS and Facebook Messenger. Messaging integrations can be attached to your Stealth bot by adding the messaging integration gem to your `Gemfile`.

## `Gemfile`

```
source 'https://rubygems.org'

ruby '2.5.1'

gem 'stealth', '~> 0.10.0'

# Uncomment to enable the Stealth Facebook Driver
# gem 'stealth-facebook'

# Uncomment to enable the Stealth Twilio SMS Driver
# gem 'stealth-twilio'
```


## `services.yml`

```yml
default: &default
  # ==========================================
  # ===== Example Facebook Service Setup =====
  # ==========================================
  # facebook:
  #   verify_token: XXXFACEBOOK_VERIFY_TOKENXXX
  #   page_access_token: XXXFACEBOOK_ACCESS_TOKENXXX
  #   setup:
  #     greeting: # Greetings are broken up by locale
  #       - locale: default
  #         text: "Welcome to the Stealth bot 🤖"
  #     persistent_menu:
  #       - type: payload
  #         text: Main Menu
  #         payload: main_menu
  #       - type: url
  #         text: Visit our website
  #         url: https://example.com
  #       - type: call
  #         text: Call us
  #         payload: "+4155330000"
  #
  # ===========================================
  # ======== Example SMS Service Setup ========
  # ===========================================
  # twilio:
  #   account_sid: XXXTWILIO_ACCOUNT_SIDXXX
  #   auth_token: XXXTWILIO_AUTH_TOKENXXX
  #   from_phone: +14155330000

production:
  <<: *default
development:
  <<: *default
test:
  <<: *default

```

## `stealth setup`

Most messaging integrations require an initial setup. For example, Facebook requires you to send a payload to define the default greeting and persistent menu. You can accomplish this by running the `stealth setup` followed by the integration. For example:

`stealth setup facebook`

Make sure to reference the respective messaging integration documentation for more specifics.

## Officially Supported

* [Facebook Messenger](https://github.com/hellostealth/stealth-facebook)
* [SMS (Twillio)](https://github.com/hellostealth/stealth-twilio)
* [Smooch (many platforms, including a web widget)](https://github.com/hellostealth/stealth-smooch)

While we plan to add more integrations in the future, please feel free to add your own and let us know so we can keep this list updated. 😎
