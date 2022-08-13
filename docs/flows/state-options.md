# State Options

In your `FlowMap`, each state may also specify certain options. Some options expose  built-in Stealth functionality, while others are completely custom and can be referenced by your code.

```ruby
class FlowMap

  include Stealth::Flow

  flow :hello do
    state :say_hello
    state :get_hello_response, fails_to: :say_hello
    state :say_hola, redirects_to: :say_hello
  end

  flow :goodbye do
    state :say_goodbye, re_engage: false
  end

  flow :interrupt do
    state :say_interrupted
  end

  flow :unrecognized_message do
    state :handle_unrecognized_message
  end

  flow :catch_all do
    state :level1
  end

end
```

We see three states have options defined: `get_hello_response`, `say_hola`, and `say_goodbye`.

#### fails\_to

The `fails_to` option is one of the built-in Stealth state options. By default, it's used in the `CatchAllsController` to specify where a user should be sent in the event of an error. We cover this more in the [CatchAll docs](../controllers/catch-alls.md), but in the `get_hello_response` state above, if Stealth encounters an error the `fails_to` option declares the user to be sent to the `say_hello` state of the same flow.

The `fails_to` value can also be a string if you wish to specify a different flow. So for example:

```ruby
state :get_hello_response, fails_to: 'goodbye->say_goodbye'
```

If Stealth encounters an error in this state, it will be sent to the `say_goodbye` state of the `goodbye` flow.

#### redirects\_to

The `redirects_to` option is useful when you're performing a rename of a state and the bot has already been deployed to production. Your production users may have existing sessions attached to the state you are renaming. If you were to perform a state rename without attaching a `redirects_to` to the old state name, the user will receive an error the next time they message your bot.

{% hint style="info" %}
For the `redirects_to`values, you can use state names as well as the "flow->state\_name" convention like in `fails_to`.
{% endhint %}

#### Custom Options

In addition to the built-in Stealth state options, you are able to define your own. This is helpful for cases where you want to define metadata for a set of states but don't want to define that logic within the controllers.

In the example `FlowMap` above, we've defined a `re_engage` option on the `say_goodbye` state. If we pretend our bot re-engages leads after a period of time, this option would be useful for allowing us to declare states for which we do not want re-engagements to be sent. In this case, the user has reached the end of the bot and so we don't want to send them any re-engagements.

You can access these custom state options via the `opts` attribute for the state specification.

```ruby
state_spec = FlowMap.flow_spec[:goodbye].states[:say_goodbye]
state_spec.opts.present? && state_spec.opts[:re_engage]
```

Here `state_spec.opts[:re_engage]` contains the value `true`. The hash key will correspond to what you named your option in the `FlowMap`.
