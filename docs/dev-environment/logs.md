# Logs

Logs are the primary visibility mechanism into your bot. Stealth logs are designed to help you debug during development and also in production.

Stealth logs all events to `stdout` instead of a log file. This avoids having to routinely clean your log files and also mimics typical production deployments.

### Interpreting Logs

Here are some sample log entries from the [Facebook Messenger](../platforms/facebook-messenger.md) platform:

```
Dec 28 18:31:33 sidekiq.1 info  pid=4 tid=590 class=Stealth::Services::HandleMessageJob jid=b08b6721a327c72aa5baa09f INFO: start
Dec 28 18:31:33 sidekiq.1 info  TID-58w [user] User 3772279279459415 -> Received Message: What is Stealth?
Dec 28 18:31:33 sidekiq.1 info  TID-58w [facebook] Requested user profile for 3772279279459415. Response: 200: {"id":"3772279279459415","name":"Leroy Jenkins","first_name":"Leroy","last_name":"Jenkins","profile_pic":"https:\/\/picsum.photos\/400"}
Dec 28 18:31:33 sidekiq.1 info  TID-58w [primary_session] User 3772279279459415: setting session to hellos->say_hello
Dec 28 18:31:33 sidekiq.1 info  TID-58w [previous_session] User 3772279279459415: setting to 
Dec 28 18:31:33 web.1     info  TID-5hs [facebook] Received webhook.
Dec 28 18:31:34 sidekiq.1 info  TID-58w [facebook] Transmitted. Response: 200: {"recipient_id":"3772279279459415"}
Dec 28 18:31:34 sidekiq.1 info  TID-58w [facebook] User 3772279279459415 -> Sending: <typing indicator>
Dec 28 18:31:37 sidekiq.1 info  TID-58w [facebook] Transmitted. Response: 200: {"recipient_id":"3772279279459415","message_id":"m_aukUQrqKbnxqm9FT6nBdZuuz3dIn4BVeTi4JX4XD8lJ2fSuuNXpN7SZkouaoC7SRrdrSDsqF--2Gi0KFZHkFNg"}
Dec 28 18:31:37 sidekiq.1 info  TID-58w [facebook] User 3772279279459415 -> Sending: Hey Leroy, 👋 welcome to Stealth!
Dec 28 18:31:37 sidekiq.1 info  TID-58w [facebook] Transmitted. Response: 200: {"recipient_id":"3772279279459415"}
Dec 28 18:31:37 sidekiq.1 info  TID-58w [facebook] User 3772279279459415 -> Sending: <typing indicator>
Dec 28 18:31:42 sidekiq.1 info  TID-58w [facebook] Transmitted. Response: 200: {"recipient_id":"3772279279459415","message_id":"m_5Dm01zkLp0Fj44QhvWYpq-uz3dIn4BVeTi4JX4XD8lLRkdqJ3g0yw0RA30Cpb06rkJPfDNGYs6BCV769e-nb7Q"}
Dec 28 18:31:42 sidekiq.1 info  TID-58w [facebook] User 3772279279459415 -> Sending: Stealth is one of the fastest ways to create a bot.
Dec 28 18:31:42 sidekiq.1 info  TID-58w [facebook] Transmitted. Response: 200: {"recipient_id":"3772279279459415"}
Dec 28 18:31:42 sidekiq.1 info  TID-58w [facebook] User 3772279279459415 -> Sending: <typing indicator>
Dec 28 18:31:49 sidekiq.1 info  TID-58w [facebook] Transmitted. Response: 200: {"recipient_id":"3772279279459415","message_id":"m_s9FICmzHaIi2hEVm2NDDvOuz3dIn4BVeTi4JX4XD8lJlfF98sBAAIos0GgjxrV4tNvIxq9_MW9qqPTO45e6gIA"}
Dec 28 18:31:49 sidekiq.1 info  TID-58w [facebook] User 3772279279459415 -> Sending: Ready to get started?
Dec 28 18:31:49 sidekiq.1 info  TID-58w [primary_session] User 3772279279459415: setting session to hellos->get_hello_response
Dec 28 18:31:49 sidekiq.1 info  TID-58w [previous_session] User 3772279279459415: setting to hellos->say_hello
```

{% hint style="info" %}
Transcript logging is enabled for the sample entries above.
{% endhint %}

#### Session Updates

Each time Stealth changes the session for a user, the `previous_session` is stored as well. On Line 5 above, you can see the user does not have a previous session (`nil`) and so on Line 4 they are being sent to `hellos->say_hello`.

After the replies are sent, you can see the session is updated again on Line 19 to `hellos->get_hello_response`. This time on Line 20 you can see there is a previous session to set and so we do.

For more info about sessions and why Stealth stores the previous session, check out the [Session docs](../controllers/sessions/intro.md).

#### Thread IDs

Often times in production, you'll see a lot of entries all interlaced together depending on your bot's load. In the example above, there isn't a lot going on, but nonetheless you can see a couple different threads logging their events.

Thread IDs begin with the prefix `TID-` followed by an alphanumeric string. Threads that have the same ID are the same thread. So in the example above, `TID-58w` are all the same background job started on Line 2. Following this thread ID will allow us to follow all the steps taken by this background job without getting confused by unrelated events.

#### Event Topics

After the thread ID, you can see the event topic wrapped in brackets (`[facebook]`). These will be color coded in your console. Session change events, component events, user events, etc are all labeled accordingly.

#### Finding Events For a User

Each Stealth component is designed to output the user's `session_id` where applicable. In the example above, you can see each Facebook entry is prefixed with `User 3772279279459415`.&#x20;

In production this would allow you to search for the user's ID (`3772279279459415`) and you would be able to see all events for the user. This is really helpful for debugging.

### Transcript Logging

In order to see what your users type, in addition to what your bot sends out, you'll need to enable the transcript logging config setting. Check out the [docs for config settings](../config/settings.md).

### Logging Custom Events

If you want to add your own custom events to the log stream, you can use the Stealth`::Logger` class to log those events. This ensures your events will appear formatted like the stock Stealth events. The API for event logging is:

```ruby
Stealth::Logger.l(topic: 'your_topic', message: 'Your message.')
```

The `topic` can be any topic of your choosing and `message` is the string you want to log. If available, you'll want to include the user's `session_id` in the `message`. This will help you tail your logs for events related to particular user.
