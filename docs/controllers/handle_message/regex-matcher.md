# Regex Matcher

When using the [string matcher](string-mather.md), you might have a scenario where the option you present to user for selection is longer or contains more detail than the answer they type. In these cases, it's useful to be able to use a regex to match a just a part of a message.

{% hint style="info" %}
The regex matcher is not limited to this use case. You can use the full power of Ruby regexes.
{% endhint %}

## Example

Given this reply to a user:

```
What would you like to do?

Reply with:
"A" for I'd like to restart
"B" for Just stop
"C" for Repeat
```

We can take advantage of the regex matcher for options "A" and "B" since it's unlikely a user would type that entire string with the formatting we expect.

```ruby
def get_response
  handle_message(
    /restart/  => proc { step_to flow: :hello },
    /stop/  => proc { 
      current_user.opt_out!
      step_to flow: :opt_out 
    },
    'Repeat' => proc { step_to session: previous_session }
  )
end
```

Now if a user types "restart" or "restart plz" it will still match the first match arm. Similarly, if they type "stop" it will match the second match arm. But just as before, typing "just stop" and "B" will also match the second match arm.

{% hint style="info" %}
Notice how we are able to mix matchers in the same `handle_message` method.
{% endhint %}
