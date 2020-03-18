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
      case generator
      when 'migration'
        Stealth::Migrations::Generator.migration(name)
      when 'flow'
        Stealth::Generators::Generate.start([generator, name])
      else
        puts "Could not find generator '#{generator}'."
        puts "Run `stealth help generate` for more options."
      end
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


    desc 'sessions:clear', 'Clears all sessions in development'
    long_desc <<-EOS
    `stealth sessions:clear` clears all sessions from Redis in development.

    $ > stealth sessions:clear
    EOS
    define_method 'sessions:clear' do
      Stealth.load_environment
      $redis.flushdb if Stealth.env.development?
    end


    desc 'db:create', 'Creates the database from DATABASE_URL or config/database.yml for the current STEALTH_ENV'
    long_desc <<-EOS
    `stealth db:create` Creates the database from DATABASE_URL or config/database.yml for the current STEALTH_ENV (use db:create:all to create all databases in the config). Without STEALTH_ENV or when STEALTH_ENV is development, it defaults to creating the development and test databases.

    $ > stealth db:create
    EOS
    define_method 'db:create' do
      Kernel.exec('bundle exec rake db:create')
    end


    desc 'db:create:all', 'Creates all databases from DATABASE_URL or config/database.yml'
    long_desc <<-EOS
    `stealth db:create:all` Creates all databases from DATABASE_URL or config/database.yml regardless of the enviornment specified in STEALTH_ENV

    $ > stealth db:create:all
    EOS
    define_method 'db:create:all' do
      Kernel.exec('bundle exec rake db:create:all')
    end


    desc 'db:drop', 'Drops the database from DATABASE_URL or config/database.yml for the current STEALTH_ENV'
    long_desc <<-EOS
    `stealth db:drop` Drops the database from DATABASE_URL or config/database.yml for the current STEALTH_ENV (use db:drop:all to drop all databases in the config). Without STEALTH_ENV or when STEALTH_ENV is development, it defaults to dropping the development and test databases.

    $ > stealth db:drop
    EOS
    define_method 'db:drop' do
      Kernel.exec('bundle exec rake db:drop')
    end


    desc 'db:drop:all', 'Drops all databases from DATABASE_URL or config/database.yml'
    long_desc <<-EOS
    `stealth db:drop:all` Drops all databases from DATABASE_URL or config/database.yml

    $ > stealth db:drop:all
    EOS
    define_method 'db:drop:all' do
      Kernel.exec('bundle exec rake db:drop:all')
    end


    desc 'db:environment:set', 'Set the environment value for the database'
    long_desc <<-EOS
    `stealth db:environment:set` Set the environment value for the database

    $ > stealth db:environment:set
    EOS
    define_method 'db:environment:set' do
      Kernel.exec('bundle exec rake db:enviornment:set')
    end


    desc 'db:migrate', 'Migrate the database'
    long_desc <<-EOS
    `stealth db:migrate` Migrate the database (options: VERSION=x, VERBOSE=false, SCOPE=blog).

    $ > stealth db:migrate
    EOS
    define_method 'db:migrate' do
      Kernel.exec('bundle exec rake db:migrate')
    end


    desc 'db:rollback', 'Rolls the schema back to the previous version'
    long_desc <<-EOS
    `stealth db:rollback` Rolls the schema back to the previous version (specify steps w/ STEP=n).

    $ > stealth db:rollback
    EOS
    define_method 'db:rollback' do
      Kernel.exec('bundle exec rake db:rollback')
    end


    desc 'db:schema:load', 'Loads a schema.rb file into the database'
    long_desc <<-EOS
    `stealth db:schema:load` Loads a schema.rb file into the database

    $ > stealth db:schema:load
    EOS
    define_method 'db:schema:load' do
      Kernel.exec('bundle exec rake db:schema:load')
    end


    desc 'db:schema:dump', 'Creates a db/schema.rb file that is portable against any DB supported by Active Record'
    long_desc <<-EOS
    `stealth db:schema:dump` Creates a db/schema.rb file that is portable against any DB supported by Active Record

    $ > stealth db:schema:dump
    EOS
    define_method 'db:schema:dump' do
      Kernel.exec('bundle exec rake db:schema:dump')
    end


    desc 'db:seed', 'Seeds the database with data from db/seeds.rb'
    long_desc <<-EOS
    `stealth db:seed` Seeds the database with data from db/seeds.rb

    $ > stealth db:seed
    EOS
    define_method 'db:seed' do
      Kernel.exec('bundle exec rake db:seed')
    end


    desc 'db:version', 'Retrieves the current schema version number'
    long_desc <<-EOS
    `stealth db:version` Retrieves the current schema version number

    $ > stealth db:version
    EOS
    define_method 'db:version' do
      Kernel.exec('bundle exec rake db:version')
    end


    desc 'db:setup', 'Creates the database, loads the schema, and initializes with the seed data (use db:reset to also drop the database first)'
    long_desc <<-EOS
    `stealth db:setup` Creates the database, loads the schema, and initializes with the seed data (use db:reset to also drop the database first)

    $ > stealth db:setup
    EOS
    define_method 'db:setup' do
      Kernel.exec('bundle exec rake db:setup')
    end


    desc 'db:structure:dump', 'Dumps the database structure to db/structure.sql. Specify another file with SCHEMA=db/my_structure.sql'
    long_desc <<-EOS
    `stealth db:structure:dump` Dumps the database structure to db/structure.sql. Specify another file with SCHEMA=db/my_structure.sql

    $ > stealth db:structure:dump
    EOS
    define_method 'db:structure:dump' do
      Kernel.exec('bundle exec rake db:structure:dump')
    end


    desc 'db:structure:load', 'Recreates the databases from the structure.sql file'
    long_desc <<-EOS
    `stealth db:structure:load` Recreates the databases from the structure.sql file

    $ > stealth db:structure:load
    EOS
    define_method 'db:structure:load' do
      Kernel.exec('bundle exec rake db:structure:load')
    end

  end
end
