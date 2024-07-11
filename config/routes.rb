# require 'multi_json'

Stealth::Engine.routes.draw do
  # Stealth Development Dashboard

  # Stealth Default Service Routes
  post 'incoming/:service', to: 'service#service_handler'
end
