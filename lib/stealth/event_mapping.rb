module Stealth
  class EventMapping
    MAPPING = {
      # slack-specific event mappings
      'slack' => {
        'text_received' => { event_type: :slack, event: :receive },
        'reaction_received' => { event_type: :slack, event: :reaction },
        'interactive_response_received' => { event_type: :slack, event: :interactive_response },
        'assistant_thread_started' => { event_type: :slack, event: :assistant_thread_started },
      }
    }.freeze

    def self.map_event(service:, event_type:)
      MAPPING.dig(service, event_type)
    end
  end
end
