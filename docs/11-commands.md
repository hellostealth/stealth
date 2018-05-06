---
title: Commands
---

Stealth provides the `stealth` command-line program, used to generate bots, generate flows, start a console, run driver setup tasks and run the server.

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
  stealth clear_sessions  # Clears all sessions in development
  stealth console         # Starts a stealth console
  stealth generate        # Generates scaffold Stealth files
  stealth help [COMMAND]  # Describe available commands or one specific command
  stealth new [NAME]      # Creates a new Stealth bot
  stealth server          # Starts a stealth server
  stealth setup           # Runs setup tasks for a specified service
  stealth version         # Prints stealth version

Examples:

  Start a new Stealth project.
  $ steath new [BOT NAME]

  Generate a new flow inside your Stealth project.
  $ stealth generate flow [FLOW NAME]

  Run setup tasks for a specific driver.
  $ stealth setup [INTEGRATION NAME]

  Start a Stealth console.
  $ stealth console
```
