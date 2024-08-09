module Stealth
  class ServiceCall

    attr_accessor :call_id, :call_url, :sender_id, :target_id, :timestamp,
                  :service, :direction, :service_event_type

    def initialize(service:)
      @service = service
    end

  end
end
