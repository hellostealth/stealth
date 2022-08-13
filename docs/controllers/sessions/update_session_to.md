# update\_session\_to

Similar to [step\_to](step\_to.md), `update_session_to` is used to update the user's session to a flow and state. It also accepts the same arguments. However, `update_session_to` does not immediately call the respective controller action. `update_session_to` is typically used after an `ask` action where the next action is waiting for user input. It allows you to set the state that will be responsible for handling that user input, like a `get` action.

{% hint style="warning" %}
If the flow and/or action specified in the `update_session_to` is not declared in the [FlowMap](../../flows/flowmap.md), Stealth will raise an exception.
{% endhint %}

## Flow Example

```ruby
update_session_to flow: 'hello'
```

Sets the session's flow to `hello` and the state will be set to the **first** state in that flow (as defined by the [FlowMap](../../flows/flowmap.md)). The corresponding controller action in the `HellosController` will **not** be called.

{% hint style="info" %}
The flow name can also be specified as a symbol.
{% endhint %}

## State Example

```ruby
update_session_to state: 'get_hello_response'
```

Sets the session's state to `get_hello_response` and keeps the flow the same. The `get_hello_response` controller action will **not** called.

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
update_session_to session: previous_session
```

Sets the session to the `previous_session` and but does **not** call the respective controller action. This is useful for updating a user's session to the previous value.
