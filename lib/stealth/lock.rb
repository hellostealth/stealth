# coding: utf-8
# frozen_string_literal: true

module Stealth
  class Lock

    include Stealth::Redis

    attr_accessor :session_id, :session_slug, :position, :tid

    def initialize(session_id:, session_slug: nil, position: nil)
      @session_id = session_id
      @session_slug = session_slug
      @position = position
      @tid = Stealth.tid
    end

    def self.find_lock(session_id:)
      lock = Lock.new(session_id: session_id)
      lock_slug = lock.slug # fetch lock from Redis

      return if lock_slug.nil?

      # parse the lock slug
      tid_and_session_slug, position = lock_slug.split(':')
      tid, session_slug = tid_and_session_slug.split('#')

      # set the values from the slug to the lock object
      lock.session_slug = session_slug
      lock.position = position&.to_i
      lock.tid = tid
      lock
    end

    def create
      if session_slug.blank?
        raise(
          ArgumentError,
          'A session_slug must be specified before a lock can be created.'
        )
      end

      # Expire locks after 30 seconds to prevent zombie locks from blocking
      # other threads to interact with a session.
      persist_key(
        key: lock_key,
        value: generate_lock,
        expiration: Stealth.config.lock_autorelease
      )
    end

    def release
      delete_key(lock_key)
    end

    def slug
      # We don't want to extend the expiration time that would result if
      # we specified one here.
      get_key(lock_key, expiration: 0)
    end

    # Returns a hash:
    #   { flow: 'flow_name', state: 'state_name' }
    def flow_and_state
      Session.flow_and_state_from_session_slug(slug: session_slug)
    end

    private

      def lock_key
        [@session_id, 'lock'].join('-')
      end

      def generate_lock
        if @position.present?
          @session_slug = [@session_slug, @position].join(':')
        end

        [@tid, @session_slug].join('#')
      end

  end
end
