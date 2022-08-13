# do\_nothing

This method is available for overriding the default behavior of Stealth which fires a [CatchAll](../catch-alls.md) in cases where a controller action fails to the update a session or send replies. See the documentation on [failing to progress a user](../controller-overview.md#failing-to-progress-a-user) for more information.

It's primarily used in states that "trap" the user (like your bot's last state or the last level of your `catch_all` flow).

It's usage is straightforward:

```ruby
def  
  do_nothing
end
```

{% hint style="info" %}
You might also use `do_nothing` within an if/else block.
{% endhint %}
