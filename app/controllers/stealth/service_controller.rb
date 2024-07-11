module Stealth
  class ServiceController < ApplicationController
    # skip the default Rails CSRF protection for webhook calls...
    skip_before_action :verify_authenticity_token, only: [:service_handler]

    def service_handler
      service = params[:service]

      case service
      when 'bandwidth'
        handle_bandwidth
      # else
      # WIP will add more services here...
      end
    end

    private

    def handle_bandwidth
      bandwidth_config = Stealth.configurations[:bandwidth]
      account_id = bandwidth_config.account_id
      api_username = bandwidth_config.api_username
      api_password = bandwidth_config.api_password
      application_id = bandwidth_config.application_id

      # WIP will trigger the stealth-bandwidth driver here...
      head :no_content
    end
  end
end
