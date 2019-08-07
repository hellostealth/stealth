# coding: utf-8
# frozen_string_literal: true

module Stealth
  module Redis
    extend ActiveSupport::Concern

    included do
      private

      def keys_expire?
        Stealth.config.session_ttl > 0
      end

      def get_key(key)
        if keys_expire?
          getex(key)
        else
          $redis.get(key)
        end
      end

      def getex(key)
        $redis.multi do
          $redis.expire(key, Stealth.config.session_ttl)
          $redis.get(key)
        end.last
      end

      def persist_key(key:, value:)
        if keys_expire?
          $redis.setex(key, Stealth.config.session_ttl, value)
        else
          $redis.set(key, value)
        end
      end

    end
  end
end
