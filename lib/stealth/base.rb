# coding: utf-8
# frozen_string_literal: true

# base requirements
require 'yaml'
require 'sidekiq'

# helpers
require 'stealth/helpers/object'

# core
require 'stealth/version'
require 'stealth/errors'
require 'stealth/jobs'
require 'stealth/server'
require 'stealth/flow/base'

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
  end

end
