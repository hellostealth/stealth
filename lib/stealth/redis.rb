# frozen_string_literal: true

require "redis"
require "connection_pool"

module Stealth
  class RedisConfig
    attr_accessor :url, :pool_size, :pool_timeout

    def initialize
      @url          = Stealth.env.development? ? "redis://localhost:6379/0" : ENV["STEALTH_REDIS_URL"] || ENV["REDIS_URL"]
      @pool_size    = Integer(ENV["STEALTH_REDIS_POOL"] || 5)
      @pool_timeout = Integer(ENV["STEALTH_REDIS_TIMEOUT"] || 5)
    end

    def to_redis_kwargs
      { url: url }
    end
  end

  module RedisSupport
    class << self
      def config
        @config ||= RedisConfig.new
      end

      def configure
        yield(config)
        reset_pool!
      end

      def pool
        @pool ||= build_pool
      end

      def with(&blk)
        pool.with(&blk)
      end

      def connection_pool
        pool
      end

      def reset_pool!
        if defined?(@pool) && @pool
          @pool.shutdown(&:close) rescue nil
        end
        @pool = nil
      end

      private

      def build_pool
        ConnectionPool.new(size: config.pool_size, timeout: config.pool_timeout) do
          ::Redis.new(**config.to_redis_kwargs)
        end
      end
    end
  end
end

