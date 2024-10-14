# frozen_string_literal: true

require 'rails/generators/base'
require 'securerandom'

module Stealth
  module Generators

    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("../../templates", __FILE__)

      desc "Creates a Stealth folder and copies Stealth template files to your application."

      def copy_initializer
        template "stealth.rb", "config/initializers/stealth.rb"
      end

      def create_stealth_folder
        empty_directory "stealth"
      end

      def copy_stealth_folders
        directory "events", "stealth/events"
        directory "flows", "stealth/flows"
        directory "models", "stealth/models"
        directory "replies", "stealth/replies"
        template "intents.rb", "stealth"
      end

      def show_readme
        readme "README" if behavior == :invoke
      end
    end
  end
end