# coding: utf-8
# frozen_string_literal: true

module Stealth
  module Migrations
    class Tasks

      class << self
        def configure
          configurator = Configurator.new

          paths = Rails.application.config.paths

          paths.add "config/database", with: configurator.config
          paths.add "db/migrate", with: configurator.migrate_dir
          paths.add "db/seeds.rb", with: configurator.seeds
        end

        def load_tasks
          configure

          Configurator.environments_config do |proxy|
            ActiveRecord::Tasks::DatabaseTasks.database_configuration = proxy.configurations
          end

          RailtieConfig.load_tasks

          # %w(
          #   connection
          #   environment
          #   db/new_migration
          # ).each do
          #   |task| load "stealth/migrations/tasks/#{task}.rake"
          # end

          load "active_record/railties/databases.rake"
        end
      end

    end
  end
end
