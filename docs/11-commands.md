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
  stealth new [NAME]            # Creates a new Stealth bot
  stealth generate flow [NAME]  # Generates a new flow (Controller, Helper and Replies)
  stealth server                # Starts a stealth server
  stealth setup [DRIVER]        # Runs setup tasks for a specified driver service
  stealth console               # Starts a stealth console
  stealth clear_sessions        # Clears all sessions in development  
  stealth help [COMMAND]        # Describe available commands or one specific command  
  stealth version               # Prints stealth version  

Examples:

  Start a new Stealth project.
  $ steath new [BOT_NAME]

  Generate a new flow inside your Stealth project.
  $ stealth generate flow [FLOW_NAME]

  Run setup tasks for a specific driver.
  $ stealth setup [DRIVER_NAME]

  Start a Stealth console.
  $ stealth console
```
