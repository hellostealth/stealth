# coding: utf-8
# frozen_string_literal: true

require 'thor'
require 'stealth/cli_base'
require 'stealth/commands/console'

module Stealth
  class Cli < Thor
    extend CliBase

    desc 'version', 'Prints stealth version'
    long_desc <<-EOS
    `stealth version` prints the version of the bundled stealth gem.
    EOS
    def version
      require 'stealth/version'
      puts "#{ Stealth::VERSION }"
    end
    map %w{--version -v} => :version


    desc 'server', 'Starts a stealth server'
    long_desc <<-EOS
    `stealth server` starts a server for the current stealth project.

    $ > stealth server

    $ > stealth server -p 4500
    EOS
    method_option :port, aliases: '-p', desc: 'The port to run the server on'
    method_option :server, desc: 'Choose a specific Rack::Handler (webrick, thin, etc)'
    method_option :rackup, desc: 'A rackup configuration file path to load (config.ru)'
    method_option :host, desc: 'The host address to bind to'
    method_option :debug, desc: 'Turn on debug output'
    method_option :warn, desc: 'Turn on warnings'
    method_option :daemonize, desc: 'If true, the server will daemonize itself (fork, detach, etc)'
    method_option :pid, desc: 'Path to write a pid file after daemonize'
    method_option :environment, desc: 'Path to environment configuration (config/environment.rb)'
    method_option :code_reloading, desc: 'Code reloading', type: :boolean, default: true
    method_option :help, desc: 'Displays the usage message'
    def server
      if options[:help]
        invoke :help, ['server']
      else
        require 'stealth/commands/server'
        Stealth::Commands::Server.new(options).start
      end
    end


    desc 'console', 'Starts a stealth console'
    long_desc <<-EOS
    `stealth console` starts the interactive stealth console.

    $ > stealth console --engine=pry
    EOS
    method_option :environment, desc: 'Path to environment configuration (config/environment.rb)'
    method_option :engine, desc: "Choose a specific console engine: (#{Stealth::Commands::Console::ENGINES.keys.join('/')})"
    method_option :help, desc: 'Displays the usage method'
    def console
      if options[:help]
        invoke :help, ['console']
      else
        Stealth::Commands::Console.new(options).start
      end
    end
  end
end
