# step\_to\_at

The `step_to_at` method is used to update the session and move the user to the specified flow and state **at the specified date and time**. `step_to_at` can accept a _flow_, a _state_, or both. `step_to_at` is often used as a tool for re-engaging a user at a specific time.

{% hint style="info" %}
The session will only be updated and the controller action called **at the time specified**.
{% endhint %}

{% hint style="warning" %}
If the flow and/or action specified in the `step_to_at` is not declared in the [FlowMap](../../flows/flowmap.md) (at the specified date and time), Stealth will raise an exception.
{% endhint %}

## Flow Example

```ruby
step_to_at Time.now.next_week, flow: 'hello'
```

At the specified time (next week in this case), Stealth will set the session's flow to `hello` and the state will be set to the **first** state in that flow (as defined by the [FlowMap](../../flows/flowmap.md)). The corresponding controller action in the `HellosController` will also be called.

{% hint style="info" %}
The flow name can also be specified as a symbol.
{% endhint %}

## State Example

```ruby
step_to_at Time.now.next_week, state: 'say_hello'
```

At the specified time (next week in this case), Stealth will set the session's state to `say_hello` and keeps the flow the same. The `say_hello` controller action will also be called.

{% hint style="info" %}
The state name can also be specified as a symbol.
{% endhint %}

## Flow and State Example

```ruby
step_to_at Time.now.next_week, flow: :hello, state: :say_hello
```

At the specified time (next week in this case), Stealth will set the session's flow to `hello` and the state to `say_hello`. The `say_hello` controller action of the `HellosController` controller will also be called.
