# require 'multi_json'

Stealth::Engine.routes.draw do
  # Stealth Development Dashboard

  # Stealth Default Service Routes
  post ':service/text_received', to: 'message#message_handler'
  post ':service/call_received', to: 'call#call_handler'
end
