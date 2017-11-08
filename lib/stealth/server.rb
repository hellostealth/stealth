# coding: utf-8
# frozen_string_literal: true

require 'sinatra/base'
require 'multi_json'

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
      Stealth::Logger.l(topic: "incoming", message: "Received webhook from #{params[:service]}")

      # JSON params need to be parsed and added to the params
      if request.env['CONTENT_TYPE'] == 'application/json'
        json_params = MultiJson.load(request.body.read)
        params.merge!(json_params)
      end

      dispatcher = Stealth::Dispatcher.new(
        service: params[:service],
        params: params,
        headers: request.env
      )

      dispatcher.coordinate
    end

  end
end
