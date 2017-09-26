require 'sinatra/base'

module Stealth
  class Server < Sinatra::Base

    get '/' do
      "Welcome to stealth."
    end

  end
end
