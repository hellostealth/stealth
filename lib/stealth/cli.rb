# coding: utf-8
# frozen_string_literal: true

require 'thor'
require 'stealth/cli_base'
require 'stealth/commands/console'
require 'stealth/generators/builder'
require 'stealth/generators/generate'

module Stealth
  class Cli < Thor
    extend CliBase

    desc 'new', 'Creates a new Stealth bot'
    long_desc <<-EOS
    `stealth new <name>` creates a new Stealth both with the given name.

    $ > stealth new new_bot
    EOS
    def new(name)
      Stealth::Generators::Builder.start([name])
    end

    desc 'generate', 'Generates scaffold Stealth files'
    long_desc <<-EOS
    `stealth generate <generator> <name>` generates scaffold Stealth files

    $ > stealth generate flow quote
    EOS
    def generate(generator, name)
      Stealth::Generators::Generate.start([generator, name])
    end
    map 'g' => 'generate'

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
    method_option :help, desc: 'Displays the usage message'
    def server
      if options[:help]
        invoke :help, ['server']
      else
        require 'stealth/commands/server'
        Stealth::Commands::Server.new(port: options.fetch(:port) { 5000 }).start
      end
    end
    map 's' => 'server'


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
    map 'c' => 'console'


    desc 'setup', 'Runs setup tasks for a specified service'
    long_desc <<-EOS
    `stealth setup <service>` runs setup tasks for the specified service.

    $ > stealth setup facebook
    EOS
    def setup(service)
      Stealth.load_environment
      service_setup_klass = "Stealth::Services::#{service.classify}::Setup".constantize
      service_setup_klass.trigger
    end


    desc 'clear_sessions', 'Clears all sessions in development'
    long_desc <<-EOS
    `stealth clear_sessions` clears all sessions from Redis in development.

    $ > stealth clear_sessions
    EOS
    def clear_sessions
      Stealth.load_environment
      $redis.flushdb if ENV['STEALTH_ENV'] == 'development'
    end
  end
end
