# coding: utf-8
# frozen_string_literal: true

require 'sinatra/base'

module Stealth
  class Server < Sinatra::Base

    def self.get_or_post(url, &block)
      get(url, &block)
      post(url, &block)
    end

    get '/' do
      "Welcome to stealth."
    end

    get_or_post '/incoming/:service' do
      dispatcher = Stealth::Dispatcher.new(
        service: params[:service],
        params: params,
        headers: request.env
      )
      dispatcher.coordinate
    end

  end
end
