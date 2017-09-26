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
      puts "v#{ Stealth::VERSION }"
    end
    map %w{--version -v} => :version

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
