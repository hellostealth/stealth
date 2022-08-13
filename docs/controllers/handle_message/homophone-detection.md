# Homophone Detection

One of the problems that arises with [alpha ordinals](alpha-ordinal-matcher.md) is that some English letters sound like other words. So for example, pronouncing "C" sounds like "see" or "sea". The letter "B" sounds like "bee" or "be". These are called homophones.

If your user is using a voice assistant to dictate their responses to your bot, it's likely the voice assistant will substitute one of these homophones for the actual letter and your bot would fail to match the user's message.

This is where homophone detection helps.

{% hint style="info" %}
Homophone detection is currently only supported for the English language.
{% endhint %}

## Example

Given this code snippet from the [Alpha Ordinal Matcher docs](alpha-ordinal-matcher.md):

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

If a user enters the letter "b", then the "Blue" match arm will automatically be selected as expected. However, Stealth will also natively accept the input "be" and "bee" from the user and the "Blue" match arm will still be selected. Similarly, "see" and "sea" will select the "Green" match arm.

{% hint style="info" %}
For a full list of homophones Stealth detects, you can inspect the array constant `Stealth::Controller::Messages::HOMOPHONES`
{% endhint %}

{% hint style="danger" %}
If you attempt to use a homophone as your match expression, Stealth will raise a `Stealth::Errors::ReservedHomophoneUsed` exception.
{% endhint %}
