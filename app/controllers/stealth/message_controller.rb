module Stealth
  class MessageController < ApplicationController
    # skip the default Rails CSRF protection for webhook calls...
    skip_before_action :verify_authenticity_token, only: [:message_handler]

    def message_handler
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
      event = Stealth::Services::Bandwidth::MessageEventHandler.determine_event_type(request)

      case event[:type]
      when :text_received
        Stealth.trigger_event(:text_message, :receive, event[:service_message])
      # when :text_message_unsubscribe
      end

      head :no_content
    end

  end
end
