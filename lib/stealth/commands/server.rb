# coding: utf-8
# frozen_string_literal: true

require 'rack/handler/puma'
require 'stealth/commands/command'

module Stealth
  module Commands
    class Server < Command
      def initialize(options)
        super(options)
        Stealth.load_environment
      end

      def start
        Rack::Handler::Puma.run(Stealth::Server)
      end
    end
  end
end
