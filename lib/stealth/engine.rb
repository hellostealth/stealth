module Stealth
  class Engine < ::Rails::Engine
    isolate_namespace Stealth

    initializer 'stealth' do
      require 'stealth/services/bandwidth/event_handler'
    end
  end
end
