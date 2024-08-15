# require 'multi_json'

Stealth::Engine.routes.draw do
  # Stealth Default Service Routes
  post '/stealth/:service', to: 'event_dispatcher#dispatch'
end
