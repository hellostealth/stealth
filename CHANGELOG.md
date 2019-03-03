# Changelog for Stealth v1.2.0

## Enhancements

* [Controller] Added a `do_nothing` method that prevents `catch_all` from firing when a controller action doesn't send replies nor progresses the session.
* [Replies] If `text` and `speech` replies are specified as an Array, Stealth will now randomize the selected text.
* [Generators] Added sample payload handling to generated bots since it can be tricky.
* [Generators] Added `inflections.rb` to generators since we rely on `ActiveSupport::Inflector` to derive flow and controller names.

## Bug Fixes

* [Sessions] Sessions retrieved when session expiration was enabled would return as an Array rather than a slug.

# Changelog for Stealth v1.1.5

## Enhancements

* [Replies] Replies will now always send the `sender_id` that came in to the service drivers. This ensures `current_session_id` hasn't been modified which would cause replies to fail to send.

# Changelog for Stealth v1.1.4

## Bug Fixes

* [General] Fixed controller and model concern load order. Previously files in the concerns folder were not loading before their respective controllers or models causing LoadErrors.

# Changelog for Stealth v1.1.3

## Bug Fixes

* [Server] Additional CONTENT_TYPE fixes that would cause the server to 500 when it was missing.

# Changelog for Stealth v1.1.2

## Bug Fixes

* [Server] Handle cases where CONTENT_TYPE is missing from incoming requests.

## Enhancements

* [CI] Added Ruby 2.6 to build.

# Changelog for Stealth v1.1.1

## Bug Fixes

* [Server] Does not auto-return an HTTP 202. Leaves it up to the drivers again.

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
* [Sessions] Sessions can now be configured to expire after a specified period of inactivity.

## Bug Fixes

* [Generators] Fixed flow generation
* [Generators] Fixed sample Facebook services.yml example

## Deprecations

* [Controllers] `current_user_id` has been soft deprecated in favor of `current_session_id`
