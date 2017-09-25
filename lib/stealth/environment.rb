require 'thread'
require 'pathname'
require 'hanami/utils'
require 'hanami/utils/hash'
require 'stealth/env'
require 'stealth/stealthrc'

module Stealth
  # Define and expose information about the Stealth environment.
  class Environment
    # Global lock (used to serialize process of environment configuration)
    LOCK = Mutex.new

    # Standard Rack ENV key
    RACK_ENV       = 'RACK_ENV'.freeze

    # Standard Stealth ENV key
    STEALTH_ENV      = 'STEALTH_ENV'.freeze

    # Default Stealth environment
    DEFAULT_ENV    = 'development'.freeze

    # Production environment
    PRODUCTION_ENV = 'production'.freeze

    # Rack production environment (aka deployment)
    RACK_ENV_DEPLOYMENT = 'deployment'.freeze

    # Default `.env` per environment file name
    DEFAULT_DOTENV_ENV = '.env.%s'.freeze

    # Default configuration directory under application root
    DEFAULT_CONFIG = 'config'.freeze

    # Standard Stealth host ENV key
    STEALTH_HOST      = 'STEALTH_HOST'.freeze

    # Default HTTP host
    DEFAULT_HOST    = 'localhost'.freeze

    # Default IP address listen
    LISTEN_ALL_HOST = '0.0.0.0'.freeze

    # Standard Stealth port ENV key
    STEALTH_PORT   = 'STEALTH_PORT'.freeze

    # Default Stealth HTTP port
    DEFAULT_PORT = 5000

    # Default Rack configuration file
    DEFAULT_RACKUP       = 'config.ru'.freeze

    # Default environment configuration file
    DEFAULT_ENVIRONMENT_CONFIG = 'environment'.freeze

    # Code reloading per environment
    CODE_RELOADING = { 'development' => true }.freeze

    CONTAINER = 'container'.freeze

    CONTAINER_PATH = 'apps'.freeze

    APPLICATION = 'app'.freeze

    APPLICATION_PATH = 'app'.freeze

    # Initialize a Stealth environment
    #
    # It accepts an optional set of configurations from the CLI commands.
    # Those settings override the defaults defined by this object.
    #
    # When initialized, it sets standard `ENV` variables for Rack and Stealth,
    # such as `RACK_ENV` and `STEALTH_ENV`.
    #
    # It also evaluates configuration from `.env` and `.env.<environment>`
    # located under the config directory. All the settings in those files will
    # be exported as `ENV` variables.
    #
    # The format of those `.env` files is compatible with `dotenv` and `foreman`
    # gems.
    #
    # @param options [Hash] override default options for various environment
    #   attributes
    #
    # @return [Stealth::Environment] the environment
    #
    # @see Stealth::Commands::Console
    # @see Stealth::Commands::Server
    # @see Stealth::Environment#config
    #
    # @example Define ENV variables from .env
    #
    #   # % tree .
    #   #   .
    #   #   # ...
    #   #   ├── .env
    #   #   └── .env.development
    #
    #   # % cat .env
    #   #   FOO="bar"
    #   #   XYZ="yes"
    #
    #   # % cat .env.development
    #   #   FOO="ok"
    #
    #   require 'stealth/environment'
    #
    #   env = STEALTH::Environment.new
    #   env.environment   # => "development"
    #
    #   # Framework defined ENV vars
    #   ENV['STEALTH_ENV']  # => "development"
    #   ENV['RACK_ENV']   # => "development"
    #
    #   ENV['STEALTH_HOST'] # => "localhost"
    #   ENV['STEALTH_PORT'] # => "2300"
    #
    #   # User defined ENV vars
    #   ENV['FOO']        # => "ok"
    #   ENV['XYZ']        # => "yes"
    #
    #   # Stealth::Environment evaluates `.env` first as master configuration.
    #   # Then it evaluates `.env.development` because the current environment
    #   # is "development". The settings defined in this last file override
    #   # the one defined in the parent (eg `FOO` is overwritten). All the
    #   # other settings (eg `XYZ`) will be left untouched.
    #   # Variables declared on `.env` and `.env.development` will not override
    #   # any variable declared on the shell when calling a `stealth` command.
    #   # Eg. In `FOO="not ok" bundle exec stealth c` `FOO` will not be overwritten
    #   # to `"ok"`.
    def initialize(options = {})
      opts     = options.to_h.dup
      @env     = Stealth::Env.new(env: opts.delete(:env) || ENV)
      @options = Stealth::Stealthrc.new(root).options
      @options.merge! Utils::Hash.new(opts.clone).symbolize!
      LOCK.synchronize { set_env_vars! }
    end

    # The current environment
    #
    # In order to decide the value, it looks up to the following `ENV` vars:
    #
    #   * STEALTH_ENV
    #   * RACK_ENV
    #
    # If those are missing it falls back to the default one: `"development"`.
    #
    # Rack environment `"deployment"` is translated to Stealth `"production"`.
    #
    # @return [String] the current environment
    #
    # @see Stealh::Environment::DEFAULT_ENV
    def environment
      @environment ||= env[STEALTH_ENV] || rack_env || DEFAULT_ENV
    end

    # @see Stealth.env?(name)
    def environment?(*names)
      names.map(&:to_s).include?(environment)
    end

    # A set of Bundler groups
    #
    # @return [Array] A set of groups
    #
    # @see http://bundler.io/v1.7/groups.html
    def bundler_groups
      [:default, environment]
    end

    # Project name
    #
    # @return [String] Project name
    def project_name
      @options.fetch(:project)
    end

    # Application's root
    #
    # It defaults to the current working directory.
    # Stealth assumes that all the commands are executed from there.
    #
    # @return [Pathname] application's root
    def root
      @root ||= Pathname.new(Dir.pwd)
    end

    # Application's config directory
    #
    # It's the application where all the configurations are stored.
    #
    # In order to decide the value, it looks up the following sources:
    #
    #   * CLI option `config`
    #
    # If those are missing it falls back to the default one: `"config/"`.
    #
    # When a relative path is given via CLI option, it assumes to be located
    # under application's root. If absolute path, it will be used as it is.
    #
    # @return [Pathname] the config directory
    #
    # @see Stealth::Environment::DEFAULT_CONFIG
    # @see Stealth::Environment#root
    def config
      @config ||= root.join(@options.fetch(:config) { DEFAULT_CONFIG })
    end

    # The HTTP host name
    #
    # In order to decide the value, it looks up the following sources:
    #
    #   * CLI option `host`
    #   * STEALTH_HOST ENV var
    #
    # If those are missing it falls back to the following defaults:
    #
    #   * `"localhost"` for development
    #   * `"0.0.0.0"` for all the other environments
    #
    # @return [String] the HTTP host name
    #
    # @see Stealth::Environment::DEFAULT_HOST
    # @see Stealth::Environment::LISTEN_ALL_HOST
    def host
      @host ||= @options.fetch(:host) do
        env[STEALTH_HOST] || default_host
      end
    end

    # The HTTP port
    #
    # In order to decide the value, it looks up the following sources:
    #
    #   * CLI option `port`
    #   * STEALTH_PORT ENV var
    #
    # If those are missing it falls back to the default one: `2300`.
    #
    # @return [Integer] the default port
    #
    # @see Stealth::Environment::DEFAULT_PORT
    def port
      @port ||= @options.fetch(:port) do
        env[STEALTH_PORT] || DEFAULT_PORT
      end.to_i
    end

    # Check if the current port is the default one
    # @see Stealth::ApplicationConfiguration#port
    def default_port?
      port == DEFAULT_PORT
    end

    # Path to the Rack configuration file
    #
    # In order to decide the value, it looks up the following sources:
    #
    #   * CLI option `rackup`
    #
    # If those are missing it falls back to the default one: `"config.ru"`.
    #
    # When a relative path is given via CLI option, it assumes to be located
    # under application's root. If absolute path, it will be used as it is.
    #
    # @return [Pathname] path to the Rack configuration file
    def rackup
      root.join(@options.fetch(:rackup) { DEFAULT_RACKUP })
    end

    # Path to environment configuration file.
    #
    # In order to decide the value, it looks up the following sources:
    #
    #   * CLI option `environment`
    #
    # If those are missing it falls back to the default one:
    # `"config/environment.rb"`.
    #
    # When a relative path is given via CLI option, it assumes to be located
    # under application's root. If absolute path, it will be used as it is.
    #
    # @return [Pathname] path to applications
    #
    # @see Stealth::Environment::DEFAULT_ENVIRONMENT_CONFIG
    def env_config
      root.join(@options.fetch(:environment) { config.join(DEFAULT_ENVIRONMENT_CONFIG) })
    end
    alias project_environment_configuration env_config

    # Require application environment
    #
    # Eg <tt>require "config/environment"</tt>.
    def require_application_environment
      require project_environment_configuration.to_s # if project_environment_configuration.exist?
    end
    alias require_project_environment require_application_environment

    # Determine if activate code reloading for the current environment while
    # running the server.
    #
    # In order to decide the value, it looks up the following sources:
    #
    #   * CLI option `code_reloading`
    #
    # If those are missing it falls back to the following defaults:
    #
    #   * true for development
    #   * false for all the other environments
    #
    # @return [TrueClass,FalseClass] the result of the check
    #
    #
    # @see Stealth::Commands::Server
    # @see Stealth::Environment::CODE_RELOADING
    def code_reloading?
      @options.fetch(:code_reloading) { !!CODE_RELOADING[environment] }
    end

    def architecture
      @options.fetch(:architecture) do
        puts "Cannot recognize Stealth architecture, please check `.stealthrc'"
        exit 1
      end
    end

    def container?
      architecture == CONTAINER
    end

    def apps_path
      @options.fetch(:path) {
        case architecture
        when CONTAINER   then CONTAINER_PATH
        when APPLICATION then APPLICATION_PATH
        end
      }
    end

    def to_options
      @options.merge(
        environment: environment,
        env_config:  env_config,
        apps_path:   apps_path,
        rackup:      rackup,
        host:        host,
        port:        port
      )
    end

    private

    attr_reader :env

    def set_env_vars!
      set_application_env_vars!
      set_stealth_env_vars!
    end

    def set_stealth_env_vars!
      env[STEALTH_ENV]  = env[RACK_ENV] = environment
      env[STEALTH_HOST] = host
      env[STEALTH_PORT] = port.to_s
    end

    def set_application_env_vars!
      dotenv = root.join(DEFAULT_DOTENV_ENV % environment)
      return unless dotenv.exist?

      env.load!(dotenv)
    end

    def default_host
      environment == DEFAULT_ENV ? DEFAULT_HOST : LISTEN_ALL_HOST
    end

    def rack_env
      case env[RACK_ENV]
      when RACK_ENV_DEPLOYMENT
        PRODUCTION_ENV
      else
        env[RACK_ENV]
      end
    end
  end
end
