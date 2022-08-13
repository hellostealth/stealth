# String Matcher

The string matcher matches exact string responses. It will however automatically ignore case and also ignore blank padding preceding and trailing a string. These blank spaces occur frequently with texting apps and autocomplete.

## Example

```ruby
def get_response
  handle_message(
    'Sure'  => proc {
      current_user.update_attributes!(interested: true)
      step_to state: :say_yes 
    },
    'Nope'  => proc { step_to state: :say_no_problem }
  )
end
```

In this example, if a user types in `SURE` or `SuRE` or `sure`, it will match the first match arm and the corresponding proc will be executed.

{% hint style="warning" %}
If none of the match expressions are matched, Stealth will raise a `Stealth::Errors::UnrecognizedMessage` exception unless the [nil matcher](nil-matcher.md) is included.
{% endhint %}
