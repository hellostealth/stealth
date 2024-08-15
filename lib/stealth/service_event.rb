module Stealth
  class ServiceEvent

    attr_accessor :sender_id,       # ID of the sender
                  :target_id,       # ID of the target recipient
                  :timestamp,       # Time when the event occurred
                  :service,         # Service associated with the event
                  :message,         # Message content
                  :payload,         # Payload information

    def initialize(service:)
      @service = service
    end

  end
end
