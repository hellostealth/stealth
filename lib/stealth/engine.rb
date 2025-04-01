module Stealth
  class Engine < ::Rails::Engine
    isolate_namespace Stealth

    # Will have to avoid loading driver files in the engine
    initializer 'stealth' do

    end
  end
end
