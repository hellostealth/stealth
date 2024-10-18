# require 'multi_json'

Stealth::Engine.routes.draw do
  # Stealth Default Service Routes
  post ':service', to: 'event#dispatch_event'
end
