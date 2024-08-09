module Stealth
  class CallController < ApplicationController
    # skip the default Rails CSRF protection for webhook calls...
    skip_before_action :verify_authenticity_token, only: [:call_handler]

    def call_handler
      service = params[:service]

      case service
      when 'bandwidth'
        handle_bandwidth(request)
      # else
      # WIP will add more services here...
      end
    end

    private

    def handle_bandwidth(request)
      event = Stealth::Services::Bandwidth::CallEventHandler.determine_event_type(request)

      case event[:type]
      when :call_received
        Stealth.trigger_event(:phone_call, :call_receive, event[:service_call])
      # when :text_message_unsubscribe
      end

      head :no_content
    end

  end
end
