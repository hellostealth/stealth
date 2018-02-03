# coding: utf-8
# frozen_string_literal: true

# base requirements
require 'yaml'
require 'sidekiq'
require 'active_support/all'

# core
require 'stealth/version'
require 'stealth/errors'
require 'stealth/logger'
require 'stealth/configuration'
require 'stealth/jobs'
require 'stealth/dispatcher'
require 'stealth/server'
require 'stealth/reply'
require 'stealth/scheduled_reply'
require 'stealth/service_reply'
require 'stealth/service_message'
require 'stealth/session'
require 'stealth/controller/callbacks'
require 'stealth/controller/catch_all'
require 'stealth/controller/helpers'
require 'stealth/controller/controller'
require 'stealth/flow/base'
require 'stealth/services/base_client'

module Stealth

  def self.env
    @env ||= ActiveSupport::StringInquirer.new(ENV['STEALTH_ENV'] || 'development')
  end

  def self.root
    @root ||= File.expand_path(Pathname.new(Dir.pwd))
  end

  def self.boot
    load_environment
  end

  def self.config
    @configuration
  end

  # Loads the services.yml configuration unless one has already been loaded
  def self.load_services_config(services_yaml)
    @semaphore ||= Mutex.new

    @configuration ||= begin
      @semaphore.synchronize do
        services_config = YAML.load(ERB.new(services_yaml).result)

        unless services_config.has_key?(env)
          raise Stealth::Errors::ConfigurationError, "Could not find services.yml configuration for #{env} environment"
        end

        Stealth::Configuration.new(services_config[env])
      end
    end
  end

  # Same as `load_services_config` but forces the loading even if one has
  # already been loaded
  def self.load_services_config!(services_yaml)
    @configuration = nil
    load_services_config(services_yaml)
  end

  def self.load_environment
    require File.join(Stealth.root, 'config', 'boot')
    require_directory("config/initializers")
    require_directory("bot")
  end

  private

    def self.require_directory(directory)
      for_each_file_in(directory) { |file| require_relative(file) }
    end

    def self.for_each_file_in(directory, &blk)
      directory = directory.to_s.gsub(%r{(\/|\\)}, File::SEPARATOR)
      directory = Pathname.new(Dir.pwd).join(directory).to_s
      directory = File.join(directory, '**', '*.rb') unless directory =~ /(\*\*)/

      Dir.glob(directory).sort.each(&blk)
    end

end
