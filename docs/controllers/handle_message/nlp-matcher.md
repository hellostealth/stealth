# NLP Matcher

NLP is a very important part of creating powerful bots. Stealth seamlessly integrates with NLP services to provide NLP matching from within the same `handle_message` method.

{% hint style="info" %}
Check out the [NLP section](../../nlp-nlu/overview.md) for more information on how to configure your NLP service to work with Stealth's `handle_message`.
{% endhint %}

## Example

Let's pretend you've trained your NLP service with some examples of "Yes" and some examples of "No". These are two common intents that you'll likely want to train for your bot. Let's also assume that we've named the "Yes" intent as `yes` and the "No" intent as `no`

{% hint style="warning" %}
Make sure you name your intents using Ruby's `snake_casing` so they easily be used in `handle_message`.
{% endhint %}

Given this reply to the user:

```
Are you interested in learning more about Stealth?

Reply with:
"A" for Yes
"B" for Remind me later
"C" for No longer interested
```

Here is what our controller action that handles this message can look like with NLP matchers:

```ruby
def get_response
  handle_message(
    :yes => proc {
      step_to state: :say_proceed
    },
    'Remind me later' => proc { step_to state: :say_no_problem },
    :no => proc { step_to state: :say_goodbye },
    :call => proc {
      step_to state: :ask_when_to_call
    }
  )
end
```

Here, we are using NLP matchers on Lines 3, 7, and 8. NLP matchers have specify match expression as a Ruby symbol.

When Stealth encounters an NLP matcher as a match expression, it will perform NLP using your configured NLP service. The result is automatically cached so that subsequent NLP matchers don't trigger another NLP lookup. The raw result of the NLP query will be stored in `current_message.nlp_result`, but `handle_message` will automatically make use of that without you having to parse it yourself.

If the resulting NLP intent is `yes` then the `:yes` match arm will be matched. The same for `:no` and `:call`. So for example, if a user type "Nah, not interested" it's likely or `:no` match arm will be called. Similarly, if a user writes "Sure!!" the `:yes` match arm will be called.

Another interesting thing to note about this example is that we have a 4th option (`:call`) that isn't explicitly mentioned in the reply to the user. With NLP matchers, it's sometimes useful to do this when your data shows that a lot users are manually typing in a custom response for a specific question. So in this case, we've asked the user if they are interested in learning more about Stealth, but some users will ask to jump on a phone call. So we've trained an NLP intent for "calls" and it will match the cases where a user requests a call for this question.
