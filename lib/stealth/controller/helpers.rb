# coding: utf-8
# frozen_string_literal: true

require "active_support/dependencies"

module Stealth
  class Controller
    module Helpers

      extend ActiveSupport::Concern

      class MissingHelperError < LoadError
        def initialize(error, path)
          @error = error
          @path  = "helpers/#{path}.rb"
          set_backtrace error.backtrace

          if error.path =~ /^#{path}(\.rb)?$/
            super("Missing helper file helpers/%s.rb" % path)
          else
            raise error
          end
        end
      end

      # class << self; attr_accessor :helpers_path; end

      included do
        class_attribute :_helpers, default: Module.new
        class_attribute :helpers_path, default: ["bot/helpers"]
        class_attribute :include_all_helpers, default: true
      end

      class_methods do
        # When a class is inherited, wrap its helper module in a new module.
        # This ensures that the parent class's module can be changed
        # independently of the child class's.
        def inherited(subclass)
          helpers = _helpers
          subclass._helpers = Module.new { include helpers }

          if subclass.superclass == Stealth::Controller && Stealth::Controller.include_all_helpers
            subclass.helper :all
          else
            subclass.class_eval { default_helper_module! } unless subclass.anonymous?
          end

          include subclass._helpers

          super
        end

        def modules_for_helpers(args)
          # Allow all helpers to be included
          args += all_bot_helpers if args.delete(:all)

          # Add each helper_path to the LOAD_PATH
          Array(helpers_path).each {|path| $:.unshift(path) }

          args.flatten.map! do |arg|
            case arg
            when String, Symbol
              file_name = "#{arg.to_s.underscore}_helper"
              begin
                require_dependency(file_name)
              rescue LoadError => e
                raise Stealth::Controller::Helpers::MissingHelperError.new(e, file_name)
              end

              mod_name = file_name.camelize
              begin
                mod_name.constantize
              rescue LoadError
                raise NameError, "Couldn't find #{mod_name}, expected it to be defined in helpers/#{file_name}.rb"
              end
            when Module
              arg
            else
              raise ArgumentError, "helper must be a String, Symbol, or Module"
            end
          end
        end

        def helper(*args, &block)
          modules_for_helpers(args).each do |mod|
            add_template_helper(mod)
          end

          _helpers.module_eval(&block) if block_given?
        end

        def default_helper_module!
          module_name = name.sub(/Controller$/, "".freeze)
          module_path = module_name.underscore
          helper module_path
        rescue LoadError => e
          raise e unless e.is_missing? "helpers/#{module_path}_helper"
        rescue NameError => e
          raise e unless e.missing_name? "#{module_name}Helper"
        end

        # Returns a list of helper names in a given path.
        #
        #   Stealth::Controller.all_helpers_from_path 'bot/helpers'
        #   # => ["bot", "estimates", "tickets"]
        def all_helpers_from_path(path)
          helpers = Array(path).flat_map do |_path|
            extract = /^#{Regexp.quote(_path.to_s)}\/?(.*)_helper.rb$/
            names = Dir["#{_path}/**/*_helper.rb"].map { |file| file.sub(extract, '\1'.freeze) }
            names.sort!
          end
          helpers.uniq!
          helpers
        end

        private
          def add_template_helper(mod)
            _helpers.module_eval { include mod }
          end

          # Extract helper names from files in "bot/helpers/**/*_helper.rb"
          def all_bot_helpers
            all_helpers_from_path(helpers_path)
          end
      end

    end
  end
end
