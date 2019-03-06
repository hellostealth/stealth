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
      <<~WELCOME
        <html>
          <head>
            <title>Stealth</title>
          </head>
          <body>
            <center>
              <a href='https://hellostealth.org'>
                <img src='http://assets.blackops.nyc/stealth/logo.svg' height='120' alt='Stealth Logo' aria-label='hellostealth.org' />
              </a>
            </center>
          </body>
        </html>
      WELCOME
    end

    get_or_post '/incoming/:service' do
      Stealth::Logger.l(topic: params[:service], message: 'Received webhook.')

      # JSON params need to be parsed and added to the params
      if request.env['CONTENT_TYPE']&.match(/application\/json/i)
        json_params = MultiJson.load(request.body.read)
        params.merge!(json_params)
      end

      dispatcher = Stealth::Dispatcher.new(
        service: params[:service],
        params: params,
        headers: get_helpers_from_request(request)
      )

      dispatcher.coordinate
    end

    private

      def get_helpers_from_request(request)
        request.env.select do |header, value|
          %w[HTTP_HOST].include?(header)
        end
      end

  end
end
