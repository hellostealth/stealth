# Changelog for Stealth v1.1.0

## Breaking Changes

* [Sidekiq] Sidekiq queues have been renamed from `webhooks` and `default` to `stealth_webhooks` and `stealth_replies`. Please ensure your `Procfile` is adjusted accordingly.
* [Flows] `flow_map.current_state.fails_to` now returns a `Stealth::Session` instead of a `Stealth::Flow::State`. This might affect your `catch_alls`.

## Enhancements

* [Controllers] `current_session_id` now references the session ID in controllers
* [Replies] Added support for dynamic delays
* [Replies] Added support for service-specific variants
* [Models] ActiveRecord is now part of the generated bot Gemfile and can be removed from bots
* [Flows] Added support for `redirects_to` during state declaration. If specified, will automatically step a user to the specified state or session.
* [Flows] `redirects_to` and `fails_to` now support a session string as an argument (`my_flow->some_state`). This allows you to fail and redirect to other flows. A state name specified as a string or symbol is still allowed.
* [Errors] Backtraces are now more readable in logs

## Bug Fixes

* [Generators] Fixed flow generation
* [Generators] Fixed sample Facebook services.yml example

## Deprecations

* [Controllers] `current_user_id` has been soft deprecated in favor of `current_session_id`
