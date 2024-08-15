# coding: utf-8
# frozen_string_literal: true

# base requirements
# require 'yaml'
# require 'sidekiq'
# require 'redis'
# require 'active_support/all'

# core
require 'stealth/version'
require "stealth/engine"
require "stealth/version"
require "stealth/engine"
require "stealth/configuration/bandwidth"
require "stealth/configuration/slack"
require "stealth/event_manager"
require "stealth/event_triggers"
require "stealth/service_message"
require "stealth/service_call"

require 'stealth/errors'
require 'stealth/logger'
# require 'stealth/core_ext'
# require 'stealth/configuration'
# require 'stealth/reloader'

# services
require 'stealth/services/base_client'

# helpers
# require 'stealth/helpers/redis'

# module Stealth

#   def self.env
#     @env ||= ActiveSupport::StringInquirer.new(ENV['STEALTH_ENV'] || 'development')
#   end

#   def self.root
#     @root ||= File.expand_path(Pathname.new(Dir.pwd))
#   end

#   def self.boot
#     load_services_config
#     load_environment
#   end

#   def self.config
#     Thread.current[:configuration] ||= load_services_config
#   end

#   def self.configuration=(config)
#     Thread.current[:configuration] = config
#   end

#   def self.default_autoload_paths
#     [
#       File.join(Stealth.root, 'bot', 'controllers', 'concerns'),
#       File.join(Stealth.root, 'bot', 'controllers'),
#       File.join(Stealth.root, 'bot', 'models', 'concerns'),
#       File.join(Stealth.root, 'bot', 'models'),
#       File.join(Stealth.root, 'bot', 'helpers'),
#       File.join(Stealth.root, 'config')
#     ]
#   end

#   def self.bot_reloader
#     @bot_reloader
#   end

#   def self.set_config_defaults(config)
#     defaults = {
#       dynamic_delay_muliplier: 1.0,                     # values > 1 increase, values < 1 decrease delay
#       session_ttl: 0,                                   # 0 seconds; don't expire sessions
#       lock_autorelease: 30,                             # 30 seconds
#       transcript_logging: false,                        # show user replies in the logs
#       hot_reload: Stealth.env.development?,             # hot reload bot files on change (dev only)
#       eager_load: Stealth.env.production?,              # eager load bot files for performance (prod only)
#       autoload_paths: Stealth.default_autoload_paths,   # array of autoload paths used in eager and hot reloading
#       autoload_ignore_paths: [],                        # paths to exclude from eager and hot reloading
#       nlp_integration: nil,                             # NLP service to use, defaults to none
#       log_all_nlp_results: false,                       # log NLP service requests; useful for debugging/improving NLP models
#       auto_insert_delays: true                          # automatically insert delays/typing indicators between all replies
#     }
#     defaults.each { |option, default| config.set_default(option, default) }
#   end

#   # Loads the services.yml configuration unless one has already been loaded
#   def self.load_services_config(services_yaml=nil)
#     @semaphore ||= Mutex.new
#     services_yaml ||= Stealth.load_services_config(
#       File.read(File.join(Stealth.root, 'config', 'services.yml'))
#     )

#     Thread.current[:configuration] ||= begin
#       @semaphore.synchronize do
#         services_config = YAML.safe_load(ERB.new(services_yaml).result, aliases: true)

#         unless services_config.has_key?(env)
#           raise Stealth::Errors::ConfigurationError, "Could not find services.yml configuration for #{env} environment"
#         end

#         config = Stealth::Configuration.new(services_config[env])
#         set_config_defaults(config)

#         config
#       end
#     end
#   end

#   # Same as `load_services_config` but forces the loading even if one has
#   # already been loaded
#   def self.load_services_config!(services_yaml=nil)
#     Thread.current[:configuration] = nil
#     load_services_config(services_yaml)
#   end

#   def self.load_bot!
#     @bot_reloader ||= begin
#       bot_reloader = Stealth::Reloader.new
#       bot_reloader.load_bot!
#       bot_reloader
#     end
#   end

#   def self.load_environment
#     require File.join(Stealth.root, 'config', 'boot')
#     require_directory('config/initializers')

#     load_bot!

#     Sidekiq.configure_server do |config|
#       config[:reloader] = Stealth.bot_reloader
#     end

#     if defined?(ActiveRecord)
#       if ENV['DATABASE_URL'].present?
#         ActiveRecord::Base.establish_connection(ENV['DATABASE_URL'])
#       else
#         database_config = File.read(File.join(Stealth.root, 'config', 'database.yml'))
#         ActiveRecord::Base.establish_connection(
#           YAML.load(ERB.new(database_config).result, aliases: true)[Stealth.env]
#         )
#       end
#     end
#   end
#
#   def self.require_directory(directory)
#     for_each_file_in(directory) { |file| require_relative(file) }
#   end

# private

#   def self.for_each_file_in(directory, &blk)
#     directory = directory.to_s.gsub(%r{(\/|\\)}, File::SEPARATOR)
#     directory = Pathname.new(Dir.pwd).join(directory).to_s
#     directory = File.join(directory, '**', '*.rb') unless directory =~ /(\*\*)/

#     Dir.glob(directory).sort.each(&blk)
#   end

# end

module Stealth

  # Thread Management
  def self.tid
    Thread.current.object_id.to_s(36)
  end    

  class << self
    include Stealth::EventTriggers

    attr_accessor :configurations

    # Setup & Service Driver Configuration

    def setup
      self.configurations ||= {}
      yield(self)
    end

    def configure_bandwidth
      self.configurations[:bandwidth] ||= Bandwidth.new
      yield(configurations[:bandwidth])
    end

    def configure_slack
      self.configurations[:slack] ||= Slack.new
      yield(configurations[:slack])
    end

  end
end