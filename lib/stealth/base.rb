# coding: utf-8
# frozen_string_literal: true

# base requirements
require 'yaml'
require 'sidekiq'
require 'active_support'

# core
require 'stealth/version'
require 'stealth/errors'
require 'stealth/jobs'
require 'stealth/server'
require 'stealth/reply'
require 'stealth/service_reply'
require 'stealth/service_message'
require 'stealth/controller'
require 'stealth/flow/base'
require 'stealth/services/base_client'

module Stealth

  def self.root
    @root ||= File.expand_path(Pathname.new(Dir.pwd))
  end

  def self.boot
    nil
  end

  def self.load_services_vars(services_yaml)
    services = YAML.load(services_yaml)
    services.each do |service, keys|
      keys.each do |key, value|
        key = [service, key].join('_').upcase
        ENV[key] = value
      end
    end
  end

  def self.load_environment
    require File.join(Stealth.root, 'config', 'boot')
    require_directory "controllers"
    require_directory "models"
    require_directory "helpers"
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
