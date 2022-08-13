# Dev Jumps

Dev Jumps are a feature of Stealth that makes you and your team more productive during development. It enables you to jump between flows and states while interacting with your bot. As you develop your bot, you can avoid having to restart the conversation each time.

{% hint style="warning" %}
Dev Jumps will only work while your bot is in the `development` environment. Dev jumps in other environments will be ignored.
{% endhint %}

## Usage

You can specify Dev Jumps in one of three ways:

1. Flow and state.
2. Just a flow name.
3. Just a state name.

{% hint style="info" %}
You can text these at any time to your bot.
{% endhint %}

### Flow and State

```
/flow_name/state_name
```

This will immediately step to the `flow_name` and `state_name` that you specified.

### Flow Name

```
/flow_name
```

This will jump the the first state declared in the [FlowMap](../flows/flowmap.md) for the flow.

### State Name

```
//state_name
```

This will jump to specified `state_name` within the current flow.

{% hint style="info" %}
Note the double forward slash `//`. This is essentially because the `flow_name` has been explicitly omitted.
{% endhint %}
