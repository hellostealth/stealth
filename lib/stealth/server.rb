# coding: utf-8
# frozen_string_literal: true

require 'sinatra/base'

module Stealth
  class Server < Sinatra::Base

    get '/' do
      "Welcome to stealth."
    end

    post '/incoming/:service' do
      dispatcher = Stealth::Dispatcher.new(
        service: params[:service],
        params: params,
        headers: request.env
      )
      dispatcher.coordinate
    end

  end
end
