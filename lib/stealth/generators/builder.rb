require 'thor/group'

module Stealth
  module Generators
    class Builder < Thor::Group
      include Thor::Actions

      argument :name

      def self.source_root
        File.dirname(__FILE__) + "/builder"
      end

      def create_bot_directory
        empty_directory(name)
      end

      def create_bot_structure
        # Bot Directory
        directory('bot', "#{name}/bot")

        # Config Directory
        directory('config', "#{name}/config")

        # Miscellaneous Files
        copy_file "config.ru", "#{name}/config.ru"
        copy_file "Gemfile", "#{name}/Gemfile"
        copy_file "README.md", "#{name}/README.md"
        copy_file "Procfile.dev", "#{name}/Procfile.dev"
      end

      def change_directory_bundle
        puts run("cd #{name} && bundle install")
      end

    end
  end
end
