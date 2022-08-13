---
description: ✨✨✨
---

# Hot-Code Reloading

Hot-code reloading is one of the more enjoyable features of using Stealth to create your bots. As you make changes to your bot, your source code is automatically loaded into memory without having to stop and start your bot!

There is nothing you need to turn on to start using this feature. As long as you are in the `development` [environment](../basics.md#environments). You may however wish to customize which files are watched for changes as you add your own custom directories, service objects, etc.

## Customizing Hot-Reload Paths

By default, these are paths and files that Stealth will watch for changes:

```
bot/controllers/conerns/*.*
bot/controllers/*.*
bot/models/concerns/*.*
bot/models/*.*
bot/helpers/*.*
config/*.*
```

In addition to your Ruby code in these directories, all reply files are automatically included since Stealth reads their contents for each message.

### Adding a File or Path to Watch

As you add your own directories to your bot, you'll want to add them to your `autoload_path` so that they can be hot-reloaded while in `development`.&#x20;

{% hint style="info" %}
In `production`Stealth will pre-load all files in the `autoload_paths` array to improve performance.
{% endhint %}

#### Adding a Single File

To add the file `lib/some_file.rb` to the `autoload_path`, add this line to `config/autoload.rb`:

```ruby
Stealth.config.autoload_paths << File.join(Stealth.root, 'lib', 'some_file')
```

{% hint style="warning" %}
Don't include the `.rb` extension to the filename.
{% endhint %}

#### Adding a Directory

To add the entire `lib` directory to the `autoload_path`, add this line to `config/autoload.rb`:

```ruby
Stealth.config.autoload_paths << File.join(Stealth.root, 'lib')
```
