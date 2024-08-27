module Stealth
  class ServiceEvent

    attr_accessor :sender_id,       # ID of the sender
                  :target_id,       # ID of the target recipient
                  :timestamp,       # Time when the event occurred
                  :service,         # Service associated with the event
                  :event_type,      # Type of event (phone, message, reaction, etc. WIP: We need to standardize these)
                  :event,           # Name of event (call, hangup, message, etc. WIP: We need to standardize these)
                  :message,         # Message content
                  :payload          # Payload information

    def initialize(service:)
      @service = service
    end

  end
end
