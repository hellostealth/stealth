# coding: utf-8
# frozen_string_literal: true

module Stealth
  class Session

    attr_reader :session

    def session
      if defined?($redis)
        @current_session ||= $redis.get(current_user_id)
      else
        raise(Stealth::RedisNotConfigured, "Please make sure REDIS_URL is configured before using sessions.")
      end
    end

  end
end
