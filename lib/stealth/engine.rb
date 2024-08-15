module Stealth
  class Engine < ::Rails::Engine
    isolate_namespace Stealth

    # Will have to avoid loading driver files in the engine
    initializer 'stealth' do
      # Not sure why we need these.
      # require 'stealth/services/bandwidth/message_event_handler'
      # require 'stealth/services/bandwidth/call_event_handler'
      # require 'stealth/services/bandwidth/service_message'
      # require 'stealth/services/bandwidth/service_call'
    end
  end
end
