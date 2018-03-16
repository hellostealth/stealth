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
        template('controllers/controller.tt', "controllers/#{name.pluralize}_controller.rb")
      end

      def create_replies
        # Sample Ask Reply
        template('replies/ask_reply.tt', "replies/#{name.pluralize}/ask_example.yml")
        # Sample Say Replies
        template('replies/say_yes_reply.tt', "replies/#{name.pluralize}/say_yes_example.yml")
        template('replies/say_no_reply.tt', "replies/#{name.pluralize}/say_no_example.yml")
      end

      def create_helper
        template('helpers/helper.tt', "helpers/#{name}_helper.rb")
      end

      def edit_flow_map
        # TODO
      end

    end
  end
end
