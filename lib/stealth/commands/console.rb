# coding: utf-8
# frozen_string_literal: true

require 'stealth/commands/command'

module Stealth
  module Commands
    # REPL that supports different engines.
    #
    # It is run with:
    #
    #   `bundle exec stealth console`
    class Console < Command
      module CodeReloading
        def reload!
          puts 'Reloading...'
          Kernel.exec "#{$PROGRAM_NAME} console"
        end
      end

      # Supported engines
      ENGINES = {
        'pry'  => 'Pry',
        'ripl' => 'Ripl',
        'irb'  => 'IRB'
      }.freeze

      DEFAULT_ENGINE = ['irb'].freeze

      attr_reader :options

      def initialize(options)
        super(options)

        @options = options
      end

      def start
        prepare
        engine.start
      end

      def engine
        load_engine options.fetch(:engine) { engine_lookup }
      end

    private

      def prepare
        # Clear out ARGV so Pry/IRB don't attempt to parse the rest
        ARGV.shift until ARGV.empty?

        # Add convenience methods to the main:Object binding
        TOPLEVEL_BINDING.eval('self').__send__(:include, CodeReloading)

        Stealth.load_environment
      end

      def engine_lookup
        (ENGINES.find { |_, klass| Object.const_defined?(klass) } || DEFAULT_ENGINE).first
      end

      def load_engine(engine)
        require engine
      rescue LoadError
      ensure
        return Object.const_get(
          ENGINES.fetch(engine) do
            raise ArgumentError.new("Unknown console engine: `#{engine}'")
          end
        )
      end
    end
  end
end
