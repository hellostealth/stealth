---
title: Commands
---

Stealth provides the `stealth` command-line program. It is used to generate new bots, generate flows, start a console, run integration setup tasks, run the server, and more.

To view details for a command at any time use `stealth help`.

```
Usage:

  stealth [<flags>] <command> [<args> ...]

Flags:

  -h, --help           Output usage information.
  -C, --chdir="."      Change working directory.
  -v, --verbose        Enable verbose log output.
      --format="text"  Output formatter.
      --version        Show application version.

Commands:  
stealth console             # Starts a stealth console
stealth db:create           # Creates the database from DATABASE_URL or config/database.yml for the current STEALTH_ENV
stealth db:create:all       # Creates all databases from DATABASE_URL or config/database.yml
stealth db:drop             # Drops the database from DATABASE_URL or config/database.yml for the current STEALTH_ENV
stealth db:drop:all         # Drops all databases from DATABASE_URL or config/database.yml
stealth db:environment:set  # Set the environment value for the database
stealth db:migrate          # Migrate the database
stealth db:rollback         # Rolls the schema back to the previous version
stealth db:schema:dump      # Creates a db/schema.rb file that is portable against any DB supported by Active Record
stealth db:schema:load      # Loads a schema.rb file into the database
stealth db:seed             # Seeds the database with data from db/seeds.rb
stealth db:setup            # Creates the database, loads the schema, and initializes with the seed data (use db:reset to also drop the database first)
stealth db:structure:dump   # Dumps the database structure to db/structure.sql. Specify another file with SCHEMA=db/my_structure.sql
stealth db:structure:load   # Recreates the databases from the structure.sql file
stealth db:version          # Retrieves the current schema version number
stealth generate            # Generates scaffold Stealth files
stealth help [COMMAND]      # Describe available commands or one specific command
stealth new                 # Creates a new Stealth bot
stealth server              # Starts a stealth server
stealth sessions:clear      # Clears all sessions in development
stealth setup               # Runs setup tasks for a specified service
stealth version             # Prints stealth version

Examples:

  Start a new Stealth project.
  $ stealth new [BOT NAME]

  Generate a new flow inside your Stealth project.
  $ stealth generate flow [FLOW NAME]

  Run setup tasks for a specific driver.
  $ stealth setup [INTEGRATION NAME]

  Start a Stealth console.
  $ stealth c

  Start the Stealth server.
  $ stealth s
```
