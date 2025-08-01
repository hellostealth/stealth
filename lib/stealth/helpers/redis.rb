# coding: utf-8
# frozen_string_literal: true

module Stealth
  module Redis
    extend ActiveSupport::Concern

    included do
      private

      def get_key(key, expiration: Stealth.config.session_ttl)
        if expiration > 0
          getex(key, expiration)
        else
          $redis.with { |r| r.get(key) }
        end
      end

      def delete_key(key)
        $redis.with { |r| r.del(key) }
      end

      def getex(key, expiration=Stealth.config.session_ttl)
        $redis.with do |r|
          r.multi do |pipeline|
            pipeline.expire(key, expiration)
            pipeline.get(key)
          end.last
        end
      end

      def persist_key(key:, value:, expiration: Stealth.config.session_ttl)
        if expiration > 0
          $redis.with { |r| r.setex(key, expiration, value) }
        else
          $redis.with { |r| r.set(key, value) }
        end
      end

    end
  end
end
