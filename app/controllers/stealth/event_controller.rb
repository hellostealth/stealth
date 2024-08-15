module Stealth
  class EventController < ApplicationController
    # skip the default Rails CSRF protection for webhook calls...
    skip_before_action :verify_authenticity_token, only: [:dispatch]

    def dispatch
      Stealth::Logger.l(topic: params[:service], message: 'Received webhook.')

      # JSON params need to be parsed and added to the params
      if request.env['CONTENT_TYPE']&.match(/application\/json/i)
        json_params = MultiJson.load(request.body.read)
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

    # def handle_bandwidth(request)
    #   event = Stealth::Services::Bandwidth::ServiceEventHandler.determine_event_type(request)

    #   case event[:type]
    #   when :text_received
    #     Stealth.trigger_event(:text_message, :receive, event[:service_message])
    #   # when :text_message_unsubscribe
    #   end

    #   head :no_content
    # end

  end
end
