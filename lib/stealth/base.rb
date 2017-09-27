# coding: utf-8
# frozen_string_literal: true

require 'stealth/version'
require 'stealth/server'
require 'stealth/flow/base'

module Stealth

  def self.root
    @root ||= File.expand_path(Pathname.new(Dir.pwd))
  end

  def self.boot
    nil
  end

  def self.load_environment
    require File.join(Stealth.root, 'config', 'boot')
  end

end
