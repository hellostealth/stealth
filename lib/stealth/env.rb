begin
  require 'dotenv/parser'
rescue LoadError
end

module Stealth
  # Encapsulate access to ENV
  class Env
    # Create a new instance
    #
    # @param env [#[],#[]=] a Hash like object. It defaults to ENV
    #
    # @return [Stealth::Env]
    def initialize(env: ENV)
      @env = env
    end

    # Return a value, if found
    #
    # @param key [String] the key
    #
    # @return [String,NilClass] the value, if found
    def [](key)
      @env[key]
    end

    # Sets a value
    #
    # @param key [String] the key
    # @param value [String] the value
    def []=(key, value)
      @env[key] = value
    end

    # Loads a dotenv file and updates self
    #
    # @param path [String, Pathname] the path to the dotenv file
    #
    # @return void
    def load!(path)
      return unless defined?(Dotenv::Parser)

      contents = ::File.open(path, "rb:bom|utf-8", &:read)
      parsed   = Dotenv::Parser.call(contents)

      parsed.each do |k, v|
        next if @env.has_key?(k)

        @env[k] = v
      end
      nil
    end
  end
end
