# Alpha Ordinal Matcher

Alpha ordinals are a way of providing "quick replies" for messaging services that do not support them natively, such as SMS and Whatsapp. With `handle_message`, they are supported directly.

## Example

Imagine you send a user this reply:

```
What's your favorite color?

Reply with:
"A" for Red
"B" for Blue
"C" for Green
"D" for Yellow
```

{% hint style="info" %}
Stealth's Twilio component can automatically generate these for you. This is covered in depth in the [YAML Replies docs](../../replies/yaml-replies.md).
{% endhint %}

The corresponding `handle_message` method would look like this:

```ruby
def get_response
  handle_message(
    'Red' => proc { current_user.update_attributes!(favorite_color: 'red') },
    'Blue' => proc { current_user.update_attributes!(favorite_color: 'blue') },
    'Green' => proc { current_user.update_attributes!(favorite_color: 'green') },
    'Yellow' => proc { current_user.update_attributes!(favorite_color: 'yellow') }
  )
end
```

With alpha ordinals, if a user types "C", then the `Green` match arm is automatically selected since it is the 3rd match expression (Line 5) specified in `handle_message`. Similarly, the user could still reply with "green" directly and that will also match the 3rd match expression (Line 5).

{% hint style="warning" %}
If a user were to type, "E", then Stealth will still raise a `Stealth::Errors::UnrecognizedMessage` exception.
{% endhint %}
