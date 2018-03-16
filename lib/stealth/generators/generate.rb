require 'thor/group'

module Stealth
  module Generators
    class Generate < Thor::Group
      include Thor::Actions

      argument :generator
      argument :name

      def hi
        say "nice #{generator} name: #{name}"
      end

    end
  end
end
