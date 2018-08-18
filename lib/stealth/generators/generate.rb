# coding: utf-8
# frozen_string_literal: true

require 'thor/group'

module Stealth
  module Generators
    class Generate < Thor::Group
      include Thor::Actions

      argument :generator
      argument :name

      def self.source_root
        File.dirname(__FILE__) + "/generate/flow"
      end

      def create_controller
        template('controllers/controller.tt', "bot/controllers/#{name.pluralize}_controller.rb")
      end

      def create_replies
        # Sample Ask Reply
        template('replies/ask_example.tt', "bot/replies/#{name.pluralize}/ask_example.yml.erb")
      end

      def create_helper
        template('helpers/helper.tt', "bot/helpers/#{name}_helper.rb")
      end

      def edit_flow_map
        inject_into_file "config/flow_map.rb", after: "include Stealth::Flow\n" do
          "\n\tflow :#{name} do\n\t\tstate :ask_example\n\tend\n"
        end
      end

    end
  end
end
