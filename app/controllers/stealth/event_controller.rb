module Stealth
  class EventController < ApplicationController
    # skip the default Rails CSRF protection for webhook calls...
    skip_before_action :verify_authenticity_token, only: [:dispatch_event]

    def dispatch_event
      Stealth::Logger.l(topic: params[:service], message: 'Received webhook.')

      # Convert params to a JSON-serializable plain Ruby hash
      plain_params = JSON.parse(params.to_json)

      if request.env['CONTENT_TYPE']&.match(/application\/json/i)
        json_params = MultiJson.load(request.body.read)
        plain_params.merge!(json_params)
      end

      dispatcher = Stealth::Dispatcher.new(
        service: plain_params["service"],
        params: plain_params,
        headers: get_helpers_from_request(request)
      )

      # headers 'Access-Control-Allow-Origin' => '*',
      #         'Access-Control-Allow-Methods' => ['OPTIONS', 'GET', 'POST']

      # content_type 'audio/mp3'
      # content_type 'application/octet-stream'

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
