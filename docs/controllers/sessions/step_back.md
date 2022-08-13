# step\_back

Used in conjunction with `set_back_to`, `step_back` will step the user to the flow and state specified by `set_back_to`. This is a useful feature when you're building shared flows. Like for example, if you ask a user for their name in multiple places throughout your bot. This allows you to keep your flows [DRY](https://en.m.wikipedia.org/wiki/Don't\_repeat\_yourself).

{% hint style="warning" %}
If a `back_to` session has not been set before `step_back` is called, Stealth will raise a `Xip::Errors::InvalidStateTransition` exception.
{% endhint %}

## set\_back\_to

`set_back_to` serves a similar purpose as [previous\_session](intro.md#previous-session), however, instead of being automatically set by Stealth, `set_back_to` is  user configurable.

It takes the same parameters as `step_to`:

```ruby
set_back_to state: 'say_hello'
set_back_to flow: 'hello', state: 'say_hello'
set_back_to session: previous_session
```

All three commands above are valid and will store the `back_to` session.&#x20;

{% hint style="info" %}
`back_to` sessions also expire along with the primary session and previous session (if an expiration has been set).
{% endhint %}

## Example

```ruby
class DataHelpersController < BotController
  
  def ask_for_email_address
    send_replies
    update_session_to state: :get_email_address
  end

  def get_email_address
    unless message_is_a_valid_email?
      step_to state: :say_invalid_email
      return
    end

    current_user.store(email: current_message.message)

    step_back
  end
  
  def say_invalid_email
    send_replies
    update_session_to state: :get_email_address
  end
  
end


class QuestionsController < BotController

  def ask_if_interested
    send_replies
    update_session_to state: :get_interest_response
  end

  def get_interest_response
    handle_message(
      :yes => proc {
        set_back_to state: :say_thanks
        step_to flow: :data_helper, state: :ask_for_email_address
      },
      :no => proc {
        step_to state: :say_no_worries
      }
    )
  end
  
  def say_thanks
    send_replies
  end
  
  def say_no_worries
    send_replies
  end

end
```

In the above example, we have two flows/controllers: `data_helper` and `question`. The `DataHelpersController` contains a few states for asking for an email address for the user and verifying that it looks like a legit email address. Setting it up this way allows any of our other controllers to also ask for an email address without having to duplicate these states.

On Lines 37-38, you see that we set the `back_to` session to be the `say_thanks` state. Then we step to the `data_helper` state directly via `step_to`. From the `DataHelpersController` we can continue to ask questions and update the states as needed like normal. Once we've collected the email address, we send the user "back" to the `back_to` session by calling `step_back` on Line 16.
