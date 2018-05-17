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
        template('controllers/controller.tt', "bot/bot/controllers/#{name.pluralize}_controller.rb")
      end

      def create_replies
        # Sample Ask Reply
        template('replies/ask_reply.tt', "bot/bot/replies/#{name.pluralize}/ask_example.yml")
        # Sample Say Replies
        template('replies/say_yes_reply.tt', "bot/bot/replies/#{name.pluralize}/say_yes_example.yml")
        template('replies/say_no_reply.tt', "bot/bot/replies/#{name.pluralize}/say_no_example.yml")
      end

      def create_helper
        template('helpers/helper.tt', "bot/bot/helpers/#{name}_helper.rb")
      end

      def create_model
        template('models/model.tt', "bot/bot/models/#{name}.rb")
      end

      def edit_flow_map
        inject_into_file "bot/config/flow_map.rb", after: "include Stealth::Flow\n" do
          "\n\tflow :#{name} do\n\t\tstate :ask_example\n\t\tstate :get_example\n\t\tstate :say_yes_example\n\t\tstate :say_no_example\n\tend\n\n"
        end
      end

    end
  end
end
