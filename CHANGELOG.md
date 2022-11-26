# Changelog for Stealth v2.0.0

## Enhancements

* Added support for Ruby 3.0
* [Controllers] Added support for Dev Jumping. This feature allows developers to jump around flows and states for bot's in development.
* [NLP] Added base classes for `Stealth::Nlp::Result` and `Stealth::Nlp::Client` to be used by NLP drivers.
* [Controllers] Scheduled replies no longer call `controller.route` when they run. Instead we `step_to` to the flow and state directly. This ensures the `route` is reserved for incoming messages.
* [Catch All] Backtrace logging has been improved. The error message is now included first in the backtrace.
* [Logger] The thread's ID (TID) is now included in every logging entry preceding the log type, ie "[facebook]"
* [Interrupt] Interrupt detection has been added. See the docs for more info on this feature.
* [Controllers] When user's flow is set to `catch_all` or `interrupt`, Stealth will ignore incoming messages. If you have interactive states in either of these controllers, you will need to move those interactions to a different controller.
* [Sessions] Sessions can now be cleared by calling `session.clear_session`. Clearing a session removes the key from Redis.
* [Logging] `primary_session`, `previous_session`, and `back_to_session` now explicitly logged
* [Sessions] The session is no longer set on update or stepping witht destination flow and state match the existing session.
* [Scheduled Replies] The `service_message.target_id` is now set for scheduled replies. NOTE: scheduled replies that are already enqueued will NOT have this set.
* [Server] Updated to Puma 6.x
* [Server] Updated to Sidekiq 7.x
* [Server] Updated to Sinatra 3.x
* [Sessions] Added `to_s` for sessions to pretty print the slug. Useful when debugging.
* `send_reples` now supports two additional options for replies:
  `send_replies(custom_reply: 'hello/say_hello')`
  `send_replies(inline: [])`
* Dynamic delays for SMS platforms do not delay at the beginning of a reply.
* Added support for Bandwidth SMS
* The `ServiceMessage` (current_message) now contains a `target_id`. This can be set by the platform driver to provide more information about the intended target of a message.
* [Controller] Added a `do_nothing` method that prevents `catch_all` from firing when a controller action doesn't send replies nor progresses the session.
* [Replies] If `text` and `speech` replies are specified as an Array, Stealth will now randomize the selected text.
* [Generators] Added sample payload handling to generated bots since it can be tricky.
* [Generators] Added `inflections.rb` to generators since we rely on `ActiveSupport::Inflector` to derive flow and controller names.
* [Sessions] previous_session log entries now appear below current_session entries.
* [Logging] Add option, `Stealth.config.transcript_logging`, to log incoming and outgoing messages.
* [Server] The only HTTP header passed along to `handle_message_job` is now `HTTP_HOST`.
* [Controllers] Added `set_back_to` and `step_back` to allow user specified "redirect back". Useful for multi-state transitions that would otherwise not be possible with just `previous_session`.
* [Configuration] Stealth::Configuration now returns `nil` for a configuration option that is missing. It still returns a `NoMethodError` if attempting to access a key from a parent node that is also missing.
* [Reloading] Bots in development mode now hot reload! It's no longer necessary to stop your local server.
* [Production] Production bots now eager load bot code to improve copy-on-write performance. The `puma.rb` config has been updated with instructions for multiple workers.
* [Flows] You can now specify custom options when defining states. These options can later be accessed via the flow specification.
* [CoreExt] Added a `String#without_punctuation` method. Removes a lot of common punctuation.
* [CoreExt] `String#normalize` no longer removes quotation marks.
* [Controllers] Alpha ordinal checks are now done against a "normalized" string without punctuation. See above.
* [Controllers] `normalized_msg` and `homophone_translated_msg` are now memoized for performance.
* [Errors] `Stealth::Errors::MessageNotRecognized` has been renamed to `Stealth::Errors::UnrecognizedMessage`
* [Controllers] When `handle_message` or `get_match` raise a `Stealth::Errors::UnrecognizedMessage`, the user is first routed to a new `UnrecognizedMessagesController` to perform NLP. If that controller fails to match, the `catch_all` is run as normal.
* [Errors] Client errors now call respective BotController actions: `handle_opt_out`, `handle_invalid_session_id`, `handle_message_filtered`, `handle_unknown_error`. Each client is responsible for raising `Stealth::Errors::UserOptOut`, `Stealth::Errors::InvalidSessionId`, `Stealth::Errors::MessageFiltered`, `Stealth::Errors::UnknownError` errors, respectively.
* [Controllers] `handle_message` and `get_match` now detect homophones for alpha ordinals (A-Z)
* [Controllers] `handle_message` and `get_match` now ignore single and double quotes for alpha-ordinals
* [CoreExt] Strings now have a `normalize` method for removing padding and quotes
* [Controllers] Improved logging when `UnrecognizedMessagesController` runs.
* [Controllers] State transitions (via `step_to`, `update_session_to`, `step_to_at`, `step_to_in`, and `set_back_to`) now accept a session `slug` argument.
* [Replies] Added support for sub-state replies. `step_to` can now take a `pos` argument that will force any resulting `send_replies` to be sent starting at the `pos` specified. `pos` can also be negative, for example, `-1` will force `send_replies` to send replies starting at (only) the last reply.
* [Replies] Dynamic delays are automatically sent before each reply. This can be disabled by setting `Stealth.config.auto_insert_delays` to `false`. If a delay is already included, the auto-delay is skipped.
* [Controllers] `handle_message` now supports `Regexp` keys.
* [Configuration] `database.yml` is now parsed with ERB in order to support environment variables. Thanks @malkovro.
* [Replies] Speech and SSML replies now use `speech` and `ssml` as keys, respectively, instead of `text`
* [Replies] Voice services (determined by having "voice" in the name) now automatically skip auto-delays.
* [Controllers] `current_message` now has a `confidence` attribute containing a float with the confidence value of the transcription (from 0 to 1).
* [Controllers] Added a `halt!` method that can be used with the controller error handlers to stop code execution.
* [Logger] If the driver makes the `translated_reply` instance variable available, it will now be logged.

## Bug Fixes

* [Catch All] Errors triggered within CatchAlls no longer trigger a CatchAll. They are simply ignored. This prevents infinite looping scenarios.
* [Interrupt] If CatchAll runs and doesn't `step_to`, it releases the session lock.
* [Controller] Messages are no longer ignored in CatchAll and Interrupt controllers
* [Interrupts] After `send_replies`, we now release the session lock. This ensures replies that send buttons can properly receive responses from them.
* Callbacks specified in child controllers of `BotController` where not being called during `step_to`. While the fix was small, we've bumped the minor release to ensure this fix does not break existing codebases.
* Fixed another bug loading replies from a `custom_reply` path in `send_replies`
* Fixed bug loading replies from a `custom_reply` path in `send_replies`
* Leading dynamic delays in a reply are not sent again on SMS platforms.
* [Sessions] Sessions retrieved when session expiration was enabled would return as an Array rather than a slug.
* [Sessions] previous_session now respects session_ttl values.
* [Catch All] Log output from all catch_all logging now includes the session_id so they can be included in log searches.
* [NLP] Strip out values from single element arrays in the case of custom LUIS List entities.
* [Config] Attempting to overwrite default config values with `nil` or `false` now correctly sets those config values.
* [Server] Added support for Bandwidth respones. (thanks @emorissettegregoire)

## Deprecations

* [Controllers] current_user_id has now been completely removed since becoming deprecated in 1.1.0.
* [Ruby] MRI 2.4 is no longer supported as we depend on ActiveSupport 6.0 now. Rails 6.0 only supports Ruby MRI 2.5+.

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
