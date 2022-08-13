# Nil Matcher

When none of the match expressions are matched in a `handle_message` method call, by default Stealth will raise a `Stealth::Errors::UnrecognizedMessage` exception. This is typically the desired behavior because it allows the [UnrecognizedMessagesController](../unrecognized-messages.md) to run.

In the event that you don't want to raise an error, like in the case where you want to just save what the user typed in and move on, you can use the nil matcher.

## Example

Given this reply to a user:

```
How much is your property worth?

Reply with:
"A" for $1 - $100
"B" for $101 - $999
"C" for $1000 - $9999
```

```ruby
def get_response
  handle_message(
    '$1 - $100' => proc { 
      current_user.update_attributes!(property_value: '$1 - $100') 
    },
    '$101 - $999' => proc { 
      current_user.update_attributes!(property_value: '$101 - $999') 
    },
    '$1000 - $9999' => proc { 
      current_user.update_attributes!(property_value: '$1000 - $9999') 
    },
    nil => proc {
      amount = current_user.message
      current_user.update_attributes!(property_value: amount)
    }
  )
end
```

In the above example, if a user enters a specific amount instead of choosing one of the ranges provided, we just store that amount and don't raise an error.

{% hint style="warning" %}
You may likely still want to verify the input they entered is a Numeric. There are also better ways to handle an example like this using [get\_match](../get\_match/).
{% endhint %}
