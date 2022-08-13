# step\_to

The `step_to` method is used to update the session and immediately move the user to the specified flow and state. `step_to` can accept a _flow_, a _state_, or both. `step_to` is often used after a `say` action where the next action typically doesn't require user input.

{% hint style="warning" %}
If the flow and/or action specified in the `step_to` is not declared in the [FlowMap](../../flows/flowmap.md), Stealth will raise an exception.
{% endhint %}

## Flow Example

```ruby
step_to flow: 'hello'
```

Sets the session's flow to `hello` and the state will be set to the **first** state in that flow (as defined by the [FlowMap](../../flows/flowmap.md)). The corresponding controller action in the `HellosController` will also be immediately called.

{% hint style="info" %}
The flow name can also be specified as a symbol.
{% endhint %}

## State Example

```ruby
step_to state: 'say_hello'
```

Sets the session's state to `say_hello` and keeps the flow the same. The `say_hello` controller action will also be immediately called.

{% hint style="info" %}
The state name can also be specified as a symbol.
{% endhint %}

## Flow and State Example

```ruby
step_to flow: :hello, state: :say_hello
```

Sets the session's flow to `hello` and the state to `say_hello`. The `say_hello` controller action of the `HellosController` controller will also be immediately called.

## Session Example

```ruby
step_to session: previous_session
```

Sets the session to the `previous_session` and immediately calls the respective controller action. This is useful for sending a user "back".
