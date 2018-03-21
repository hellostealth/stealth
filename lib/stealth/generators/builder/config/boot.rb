require 'stealth'
require_relative './environment'

Bundler.require(:default, Stealth.env)

Stealth.boot
