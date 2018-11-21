# Changelog for Stealth v1.1.0

## Breaking Changes

* [Sidekiq] Sidekiq queues have been renamed from `webhooks` and `default` to `stealth_webhooks` and `stealth_replies`. Please ensure your `Procfile` is adjusted accordingly.

## Enhancements

* [Controllers] `current_session_id` now references the session ID in controllers
* [Replies] Added support for dynamic delays
* [Models] ActiveRecord is part of the generated bot Gemfile and can be removed
* [Errors] Backtraces are now more readable in logs

## Bug Fixes

* [Generators] Fixed flow generation
* [Generators] Fixed sample Facebook services.yml example

## Deprecations

* [Controllers] `current_user_id` has been soft deprecated in favor of `current_session_id`
