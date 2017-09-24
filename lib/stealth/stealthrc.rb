require 'pathname'
require 'hanami/utils/hash'

module Stealth
  # Read the .stealthrc file in the root of the application
  class Stealthrc
    # Stealthrc name file
    #
    # @see Stealth::Stealthrc#path_file
    FILE_NAME = '.stealthrc'.freeze

    # Architecture default value
    #
    # @see Stealth::Stealthrc#options
    DEFAULT_ARCHITECTURE = 'container'.freeze

    # Application architecture value
    APP_ARCHITECTURE = 'app'.freeze

    # Architecture key for writing the stealthrc file
    #
    # @see Stealth::Stealthrc#default_options
    ARCHITECTURE_KEY = 'architecture'.freeze

    # Project name for writing the stealthrc file
    #
    # @see Stealth::Stealthrc#default_options
    PROJECT_NAME = 'project'.freeze

    # Test suite default value
    #
    # @see Stealth::Stealthrc#default_options
    DEFAULT_TEST_SUITE = 'rspec'.freeze

    # Test suite key for writing the stealthrc file
    #
    # @see Stealth::Stealthrc#default_options
    TEST_KEY = 'test'.freeze

    # Template default value
    #
    # @see Stealth::Stealthrc#default_options
    DEFAULT_TEMPLATE = 'erb'.freeze

    # Template key for writing the stealthrc file
    #
    # @see Stealth::Stealthrc#default_options
    TEMPLATE_KEY = 'template'.freeze

    # Key/value separator in stealthrc file
    SEPARATOR = '='.freeze

    # Initialize Stealthrc class with application's root and environment options.
    #
    # @param root [Pathname] Application's root
    #
    # @see Stealth::Environment#initialize
    def initialize(root)
      @root = root
    end

    # Read Stealthrc file (if exists) and parse it's values or return default.
    #
    # @return [Stealth::Utils::Hash] parsed values
    #
    # @example Default values if file doesn't exist
    #   Stealth::Stealthrc.new(Pathname.new(Dir.pwd)).options
    #    # => { architecture: 'container', test: 'minitest', template: 'erb' }
    #
    # @example Custom values if file doesn't exist
    #   options = { architect: 'application', test: 'rspec', template: 'slim' }
    #   Stealth::Stealthrc.new(Pathname.new(Dir.pwd), options).options
    #    # => { architecture: 'application', test: 'rspec', template: 'slim' }
    def options
      @options ||= symbolize(default_options.merge(file_options))
    end

    # Default values for writing the stealthrc file
    #
    # @see Stealth::Stealthrc#options
    def default_options
      @default_options ||= Utils::Hash.new({
                                           ARCHITECTURE_KEY => DEFAULT_ARCHITECTURE,
                                           PROJECT_NAME     => project_name,
                                           TEST_KEY         => DEFAULT_TEST_SUITE,
                                           TEMPLATE_KEY     => DEFAULT_TEMPLATE
                                         }).symbolize!.freeze
    end

    # Check if stealthrc file exists
    #
    # @return [Boolean] stealthrc file's path existing
    def exists?
      path_file.exist?
    end

    private

    def symbolize(hash)
      Utils::Hash.new(hash).symbolize!
    end

    # Returns options from stealthrc file
    #
    # @return [Hash] stealthrc parsed values
    def file_options
      symbolize(exists? ? parse_file(path_file) : {})
    end

    # Read stealthrc file and parse it's values
    #
    # @return [Hash] stealthrc parsed values
    def parse_file(path)
      {}.tap do |hash|
        File.readlines(path).each do |line|
          key, value = line.split(SEPARATOR)
          hash[key] = value.strip
        end
      end
    end

    # Return the stealthrc file's path
    #
    # @return [Pathname] stealthrc file's path
    #
    # @see Stealth::Stealthrc::FILE_NAME
    def path_file
      @root.join FILE_NAME
    end

    # Generates a default project name based on the application directory
    # @return [String] application_name
    #
    # @see Stealth::Stealthrc::PROJECT_NAME
    def project_name
      ::File.basename(@root)
    end
  end
end
