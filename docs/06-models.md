---
title: Models
---

Models in Stealth are powered by [ActiveRecord](http://guides.rubyonrails.org/active_record_basics.html). Your bot may not need to persist data, but if it does, ActiveRecord comes built in. We've tried to keep things identical to Ruby on Rails.

## ActiveRecord Models

An ActiveRecord model in Stealth inherits all of the functionality from [ActiveRecord](http://guides.rubyonrails.org/active_record_basics.html). An empty model looks like this in Stealth:

```ruby
class Quote < BotRecord

end
```

With the exception of inheriting from `BotRecord` instead of `ApplicationRecord`, everything else matches what is in the [ActiveRecord](http://guides.rubyonrails.org/active_record_basics.html) documentation.

## Configuration

Configuring a database is done via `config/database.yml`. A sample `database.yml` file is included when you generate your bot. It is configured to use SQLite3. For more options please refer to the [Ruby on Rails documentation](http://guides.rubyonrails.org/configuring.html#configuring-a-database).

## Migrations

In order to use your models, you'll need to generate migrations to create your database schema:

```
stealth g migration create_users
```

This will create a migration named `CreateUsers`. To migrate your database:

```
stealth db:migrate
```

For more information about migrations, seed data, creating databases, or dropping databases please refer to the [Ruby on Rails documentation](http://guides.rubyonrails.org/active_record_migrations.html).

Just remember to prefix your commands with `stealth` rather than `rails`.
