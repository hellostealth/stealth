module Stealth
  class ServiceMessage

    attr_accessor :sender_id, :target_id, :timestamp, :service, :message, :service_event_type,
                  :location, :attachments, :payload, :referral, :nlp_result,
                  :catch_all_reason, :confidence

    def initialize(service:)
      @service = service
      @attachments = []
      @location = {}
    end

  end
end
