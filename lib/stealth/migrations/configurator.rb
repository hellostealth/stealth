# coding: utf-8
# frozen_string_literal: true

module Stealth
  module Migrations
    class InternalConfigurationsProxy

      attr_reader :configurations

      def initialize(configurations)
        @configurations = configurations
      end

      def on(config_key)
        if @configurations[config_key] && block_given?
          @configurations[config_key] = yield(@configurations[config_key]) || @configurations[config_key]
        end
        @configurations[config_key]
      end
    end

    class Configurator
      def self.load_configurations
        self.new
        @env_config ||= Rails.application.config.database_configuration
        ActiveRecord::Base.configurations = @env_config
        @env_config
      end

      def self.environments_config
        proxy = InternalConfigurationsProxy.new(load_configurations)
        yield(proxy) if block_given?
      end

      def initialize(options = {})
        default_schema = ENV['SCHEMA'] || ActiveRecord::Tasks::DatabaseTasks.schema_file(ActiveRecord::Base.schema_format)
        defaults = {
          :config       => "db/config.yml",
          :migrate_dir  => "db/migrate",
          :seeds        => "db/seeds.rb",
          :schema       => default_schema
        }
        @options = defaults.merge(options)

        Rails.application.config.root = Pathname.pwd
        Rails.application.config.paths["config/database"] = config
      end

      def config
        @options[:config]
      end

      def migrate_dir
        @options[:migrate_dir]
      end

      def seeds
        @options[:seeds]
      end

      def schema
        @options[:schema]
      end

      def config_for_all
        Configurator.load_configurations.dup
      end

      def config_for(environment)
        config_for_all[environment.to_s]
      end
    end
  end
end
