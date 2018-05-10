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
        puts ascii_art
        exec "foreman start -f Procfile.dev -p #{@port}"
      end

      private

        def ascii_art
          <<~ART
                                    --
                                  -yooy-
                                -yo`  `oy-
                              -yo`      `oy-
                            -hh`          `hh-
                          -yo`/y:        :y/`oy-
                        -yo`    /y:    :y/    `oy-
                      -yo`        /y::y/        `oy-
                    -yd+           /dd/           +dy-
                  -yo` :y/       :y/  /y:       /y/ `oy-
                -yo`     :y/   :y/      /y:   /y/     `oy-
              -yo`         :yoy/          /yoy:         `oy-
              -yo`         :yoy/          /yoy:         `oy-
                -yo`     :y/   :y/      /y:   /y:     `oy-
                  -yo` :y/       :y/  /y:       /y: `oy-
                    -yh/           :yy:           /hy-


                            Stealth v#{Stealth::VERSION}

          ART
        end
    end
  end
end
