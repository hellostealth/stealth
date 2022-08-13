# step\_to\_in

The `step_to_in` method is used to update the session and move the user to the specified flow and state **after a specified duration**. `step_to_in` can accept a _flow_, a _state_, or both. `step_to_in` is often used as a tool for re-engaging a user after a specified duration.

{% hint style="info" %}
The session will only be updated and the controller action called **after the specified duration has elapsed**.
{% endhint %}

{% hint style="warning" %}
If the flow and/or action specified in the `step_to_in` is not declared in the [FlowMap](../../flows/flowmap.md) (after the specified duration), Stealth will raise an exception.
{% endhint %}

## Flow Example

```ruby
step_to_in 8.hours, flow: 'hello'
```

After the specified duration (8 hours in this case), Stealth will set the session's flow to `hello` and the state will be set to the **first** state in that flow (as defined by the [FlowMap](../../flows/flowmap.md)). The corresponding controller action in the `HellosController` will also be called.

{% hint style="info" %}
The flow name can also be specified as a symbol.
{% endhint %}

## State Example

```ruby
step_to_in 8.hours, state: 'say_hello'
```

After the specified duration (8 hours in this case), Stealth will set the session's state to `say_hello` and keeps the flow the same. The `say_hello` controller action will also be called.

{% hint style="info" %}
The state name can also be specified as a symbol.
{% endhint %}

## Flow and State Example

```ruby
step_to_in 8.hours, flow: :hello, state: :say_hello
```

After the specified duration (8 hours in this case), Stealth will set the session's flow to `hello` and the state to `say_hello`. The `say_hello` controller action of the `HellosController` controller will also be called.
