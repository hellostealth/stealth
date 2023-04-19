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
                <img src='https://raw.githubusercontent.com/hellostealth/stealth/master/logo.svg' height='120' alt='Stealth Logo' aria-label='hellostealth.org' />
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

        if bandwidth?
          if json_params.is_a?(Array)
            params.merge!(json_params.first)
          else
            return [200, 'Ok']
          end
        else
          params.merge!(json_params)
        end
      end

      dispatcher = Stealth::Dispatcher.new(
        service: params[:service],
        params: params,
        headers: get_helpers_from_request(request)
      )

      headers 'Access-Control-Allow-Origin' => '*',
              'Access-Control-Allow-Methods' => ['OPTIONS', 'GET', 'POST']
      # content_type 'audio/mp3'
      content_type 'application/octet-stream'

      dispatcher.coordinate
    end

    get_or_post '/incoming/:service/inbound_call' do
      Stealth::Logger.l(topic: params[:service], message: 'Received inbound call webhook.')

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

      headers 'Access-Control-Allow-Origin' => '*',
              'Access-Control-Allow-Methods' => ['OPTIONS', 'GET', 'POST']
      # content_type 'audio/mp3'
      content_type 'application/octet-stream'

      dispatcher.coordinate
    end

    private

      def get_helpers_from_request(request)
        request.env.select do |header, value|
          %w[HTTP_HOST].include?(header)
        end
      end

      def bandwidth?
        params[:service] == "bandwidth"
      end

  end
end
