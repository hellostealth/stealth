# coding: utf-8
# frozen_string_literal: true

require 'rack/handler/puma'
require 'stealth/commands/command'

module Stealth
  module Commands
    class Server < Command
      def initialize(port:)
        @port = port
        $stdout.sync = true
      end

      def start
        # Rack::Handler::Puma.run(Stealth::Server)
        exec "foreman start -f Procfile.dev -p #{@port}"
      end
    end
  end
end
