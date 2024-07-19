module Stealth
  class ServiceController < ApplicationController
    # skip the default Rails CSRF protection for webhook calls...
    skip_before_action :verify_authenticity_token, only: [:service_handler]

    def service_handler
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
      event_type = Stealth::Services::Bandwidth::EventHandler.determine_event_type(request)

      case event_type
      when :text_message_receive
        Stealth.trigger_event(:text_message, :receive, request)
      # when :text_message_unsubscribe
      end

      head :no_content
    end

  end
end
