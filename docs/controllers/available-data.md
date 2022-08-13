# Available Data

Within each controller action, you have access to a few objects containing information about the session and the received message.&#x20;

{% hint style="info" %}
Other Stealth components might make additional data available (e.g., sentiment analysis, etc).
{% endhint %}

## `current_message`

The current message being processed is available via `current_message`. This is a `Stealth::ServiceMessage` object. It has a few important methods:

`sender_id`: The ID of the user sending the message. This will vary based on the message service component. This is also the ID that will be used as the user's session ID.

`target_id`: The ID of the target. This will vary based on the service sending the message, but for Facebook it will be the `page_id` of the Facebook page receiving the message and for SMS will be the number receiving the SMS message. For other services, this may be `nil`.&#x20;

`timestamp`: Ruby `DateTime` object containing the timestamp of when the message was transmitted. This might differ from the current time.

`service`: String indicating the message service from where the message originated (i.e., `facebook`, or `twilio`).&#x20;

`message`: String of the message contents.

`payload`: This will vary per message service component.

`nlp_result`: The raw result of the NLP performed on this message. This will vary per NLP component.

`catch_all_reason`: This is a hash that contains two keys: `:err` and `:err_msg`. The `:err` key is a string of the exception class that was raised and the `:err_msg` is the message associated with that exception. See [Catch-All Reasons](catch-alls.md#catch-all-reasons) for more info.

`location`: This will vary per message service component.&#x20;

`attachments`: This will vary per message service component.&#x20;

`referral`: This will vary per message service component.

## `current_session`

The user's session is accessible via `current_session`. This is a `Stealth::Session` object. It has a few important methods:

`flow_string`: Returns the name of the flow.&#x20;

`state_string`: Returns the name of the state.

`to_s`: Returns the session canonical session slug string.&#x20;

`current_session + 2.states`: Returns a new session object 2 states after the current state. If we've exceeded the last state in flow (as defined in the [FlowMap](../flows/flowmap.md)), the last state is returned.

`current_session - 2.states`: Returns a new session object 2 states before the current state. If we've exceeded the first state in the flow (as defined in the [FlowMap](../flows/flowmap.md)), the first state is returned.

`==`: Compare two sessions and returns `true` if they point to the same flow and state and `false` if they do not.

{% hint style="warning" %}
Use the session arithmetic operators (`+` and `-`) sparingly. They are primarily designed for use in [Catch](catch-alls.md)[Alls](catch-alls.md) when a `fails_to` state has not been specified.
{% endhint %}

## `current_service`

Returns a string indicating the message platform from where the message originated (i.e., `facebook`, or `twilio`).&#x20;

{% hint style="info" %}
This is an alias of `current_message.service`
{% endhint %}

## `current_session_id`

Returns the session ID. This will vary by message service, but for Facebook Messenger this will be the user's PSID and for SMS and Whatsapp this will be the user's phone number in [E.164](https://en.m.wikipedia.org/wiki/E.164) format.

{% hint style="info" %}
This is an alias of `current_message.sender_id`
{% endhint %}

## `has_location?`

Returns `true` or `false` depending on whether or not the `current_message` contains location data.

## `has_attachments?`

Returns `true` or `false` depending on whether or not the `current_message` contains file or media attachments.
