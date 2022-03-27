# coding: utf-8
# frozen_string_literal: true

# base requirements
require 'yaml'
require 'sidekiq'
require 'active_support/all'

begin
  require "rails"
  require "active_record"
rescue LoadError
  # Don't require ActiveRecord
end

# core
require 'stealth/version'
require 'stealth/errors'
require 'stealth/core_ext'
require 'stealth/logger'
require 'stealth/configuration'
require 'stealth/reloader'

# helpers
require 'stealth/helpers/redis'

module Stealth

  def self.env
    @env ||= ActiveSupport::StringInquirer.new(ENV['STEALTH_ENV'] || 'development')
  end

  def self.root
    @root ||= File.expand_path(Pathname.new(Dir.pwd))
  end

  def self.boot
    load_services_config
    load_environment
  end

  def self.config
    Thread.current[:configuration] ||= load_services_config
  end

  def self.configuration=(config)
    Thread.current[:configuration] = config
  end

  def self.default_autoload_paths
    [
      File.join(Stealth.root, 'bot', 'controllers', 'concerns'),
      File.join(Stealth.root, 'bot', 'controllers'),
      File.join(Stealth.root, 'bot', 'models', 'concerns'),
      File.join(Stealth.root, 'bot', 'models'),
      File.join(Stealth.root, 'bot', 'helpers'),
      File.join(Stealth.root, 'config')
    ]
  end

  def self.bot_reloader
    @bot_reloader
  end

  def self.set_config_defaults(config)
    defaults = {
      dynamic_delay_muliplier: 1.0,                     # values > 1 increase, values < 1 decrease delay
      session_ttl: 0,                                   # 0 seconds; don't expire sessions
      lock_autorelease: 30,                             # 30 seconds
      transcript_logging: false,                        # show user replies in the logs
      hot_reload: Stealth.env.development?,             # hot reload bot files on change (dev only)
      eager_load: Stealth.env.production?,              # eager load bot files for performance (prod only)
      autoload_paths: Stealth.default_autoload_paths,   # array of autoload paths used in eager and hot reloading
      autoload_ignore_paths: [],                        # paths to exclude from eager and hot reloading
      nlp_integration: nil,                             # NLP service to use, defaults to none
      log_all_nlp_results: false,                       # log NLP service requests; useful for debugging/improving NLP models
      auto_insert_delays: true                          # automatically insert delays/typing indicators between all replies
    }
    defaults.each { |option, default| config.set_default(option, default) }
  end

  # Loads the services.yml configuration unless one has already been loaded
  def self.load_services_config(services_yaml=nil)
    @semaphore ||= Mutex.new
    services_yaml ||= Stealth.load_services_config(
      File.read(File.join(Stealth.root, 'config', 'services.yml'))
    )

    Thread.current[:configuration] ||= begin
      @semaphore.synchronize do
        services_config = YAML.load(ERB.new(services_yaml).result, aliases: true)

        unless services_config.has_key?(env)
          raise Stealth::Errors::ConfigurationError, "Could not find services.yml configuration for #{env} environment"
        end

        config = Stealth::Configuration.new(services_config[env])
        set_config_defaults(config)

        config
      end
    end
  end

  # Same as `load_services_config` but forces the loading even if one has
  # already been loaded
  def self.load_services_config!(services_yaml=nil)
    Thread.current[:configuration] = nil
    load_services_config(services_yaml)
  end

  def self.load_bot!
    @bot_reloader ||= begin
      bot_reloader = Stealth::Reloader.new
      bot_reloader.load_bot!
      bot_reloader
    end
  end

  def self.load_environment
    require File.join(Stealth.root, 'config', 'boot')
    require_directory('config/initializers')

    load_bot!

    Sidekiq.options[:reloader] = Stealth.bot_reloader

    if defined?(ActiveRecord)
      if ENV['DATABASE_URL'].present?
        ActiveRecord::Base.establish_connection(ENV['DATABASE_URL'])
      else
        database_config = File.read(File.join(Stealth.root, 'config', 'database.yml'))
        ActiveRecord::Base.establish_connection(
          YAML.load(ERB.new(database_config).result)[Stealth.env]
        )
      end
    end
  end

  def self.tid
    Thread.current.object_id.to_s(36)
  end

  def self.require_directory(directory)
    for_each_file_in(directory) { |file| require_relative(file) }
  end

private

  def self.for_each_file_in(directory, &blk)
    directory = directory.to_s.gsub(%r{(\/|\\)}, File::SEPARATOR)
    directory = Pathname.new(Dir.pwd).join(directory).to_s
    directory = File.join(directory, '**', '*.rb') unless directory =~ /(\*\*)/

    Dir.glob(directory).sort.each(&blk)
  end

end

require 'stealth/jobs'
require 'stealth/dispatcher'
require 'stealth/server'
require 'stealth/reply'
require 'stealth/scheduled_reply'
require 'stealth/service_reply'
require 'stealth/service_message'
require 'stealth/session'
require 'stealth/lock'
require 'stealth/nlp/result'
require 'stealth/nlp/client'
require 'stealth/controller/callbacks'
require 'stealth/controller/replies'
require 'stealth/controller/messages'
require 'stealth/controller/unrecognized_message'
require 'stealth/controller/catch_all'
require 'stealth/controller/helpers'
require 'stealth/controller/dynamic_delay'
require 'stealth/controller/interrupt_detect'
require 'stealth/controller/dev_jumps'
require 'stealth/controller/nlp'
require 'stealth/controller/controller'
require 'stealth/flow/base'
require 'stealth/services/base_client'

if defined?(ActiveRecord)
  require 'stealth/migrations/configurator'
  require 'stealth/migrations/generators'
  require 'stealth/migrations/railtie_config'
  require 'stealth/migrations/tasks'
end
