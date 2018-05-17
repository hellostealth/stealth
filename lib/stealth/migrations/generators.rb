# coding: utf-8
# frozen_string_literal: true

require "rails/generators"

module Stealth
  module Migrations
    class Generator
      def self.migration(name, options="")
        generator_params = [name] + options.split(" ")
        Rails::Generators.invoke("active_record:migration", generator_params,
          destination_root: Stealth.root
        )
      end
    end
  end
end
