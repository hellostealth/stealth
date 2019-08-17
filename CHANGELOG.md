# Changelog for Stealth v2.6.0

## Enhancements

* [Controllers] Added support for Dev Jumping. This feature allows developers to jump around flows and states for bot's in development.

# Changelog for Stealth v2.5.3

## Bug Fixes

* [Interrupts] After `send_replies`, we now release the session lock. This ensures replies that send buttons can properly receive responses from them.

# Changelog for Stealth v2.5.2

## Enhancements

* [Controllers] Scheduled replies no longer call `controller.route` when they run. Instead we `step_to` to the flow and state directly. This ensures the `route` is reserved for incoming messages.

# Changelog for Stealth v2.5.1

## Bug Fixes

* [Interrupt] If CatchAll runs and doesn't `step_to`, it releases the session lock.
* [Controller] Messages are no longer ignored in CatchAll and Interrupt controllers

# Changelog for Stealth v2.5.0

## Enhancements

* [Catch All] Backtrace logging has been improved. The error message is now included first in the backtrace.
* [Logger] The thread's ID (TID) is now included in every logging entry preceding the log type, ie "[facebook]"
* [Interrupt] Interrupt detection has been added. See the docs for more info on this feature.

# Changelog for Stealth v2.4.0

## Enhancements

* [Controllers] When user's flow is set to `catch_all` or `interrupt`, Stealth will ignore incoming messages. If you have interactive states in either of these controllers, you will need to move those interactions to a different controller.
* [Sessions] Sessions can now be cleared by calling `session.clear_session`. Clearing a session removes the key from Redis.
* [Logging] `primary_session`, `previous_session`, and `back_to_session` now explicitly logged
* [Sessions] The session is no longer set on update or stepping witht destination flow and state match the existing session.
* [Scheduled Replies] The `service_message.target_id` is now set for scheduled replies. NOTE: scheduled replies that are already enqueued will NOT have this set.
* [Server] Updated to Puma 4.0.1

# Changelog for Stealth v2.3.0

## Enhancements

* [Sessions] Added `to_s` for sessions to pretty print the slug. Useful when debugging.

## Bug Fixes

* Callbacks specified in child controllers of `BotController` where not being called during `step_to`. While the fix was small, we've bumped the minor release to ensure this fix does not break existing codebases.

# Changelog for Stealth v2.2.4

## Bug Fixes

* Fixed another bug loading replies from a `custom_reply` path in `send_replies`

# Changelog for Stealth v2.2.3

## Bug Fixes

* Fixed bug loading replies from a `custom_reply` path in `send_replies`

# Changelog for Stealth v2.2.2

## Enhancements

* Leading dynamic delays in a reply are not sent again on SMS platforms.

# Changelog for Stealth v2.2.0

## Enhancements

* `send_reples` now supports two additional options for replies:
  `send_replies(custom_reply: 'hello/say_hello')`
  `send_replies(inline: [])`

# Changelog for Stealth v2.1.0

## Enhancements

* Dynamic delays for SMS platforms do not delay at the beginning of a reply.
* Added support for Bandwidth SMS
* The `ServiceMessage` (current_message) now contains a `target_id`. This can be set by the platform driver to provide more information about the intended target of a message.

# Changelog for Stealth v2.0.0

## Enhancements

* [Controller] Added a `do_nothing` method that prevents `catch_all` from firing when a controller action doesn't send replies nor progresses the session.
* [Replies] If `text` and `speech` replies are specified as an Array, Stealth will now randomize the selected text.
* [Generators] Added sample payload handling to generated bots since it can be tricky.
* [Generators] Added `inflections.rb` to generators since we rely on `ActiveSupport::Inflector` to derive flow and controller names.
* [Sessions] previous_session log entries now appear below current_session entries.
* [Logging] Add option, `Stealth.config.transcript_logging`, to log incoming and outgoing messages.
* [Server] The only HTTP header passed along to `handle_message_job` is now `HTTP_HOST`.
* [Controllers] Added `set_back_to` and `step_back` to allow user specified "redirect back". Useful for multi-state transitions that would otherwise not be possible with just `previous_session`.

## Bug Fixes

* [Sessions] Sessions retrieved when session expiration was enabled would return as an Array rather than a slug.
* [Sessions] previous_session now respects session_ttl values.

## Deprecations

* [Controllers] current_user_id has now been completely removed since becoming deprecated in 1.1.0.

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
