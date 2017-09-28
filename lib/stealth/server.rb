# coding: utf-8
# frozen_string_literal: true

require 'sinatra/base'

module Stealth
  class Server < Sinatra::Base

    get '/' do
      "Welcome to stealth."
    end

  end
end
