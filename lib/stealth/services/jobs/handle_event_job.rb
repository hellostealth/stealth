# coding: utf-8
# frozen_string_literal: true

module Stealth
  module Services

    class HandleEventJob < Stealth::Jobs
      sidekiq_options queue: :stealth3_webhooks, retry: false

      def perform(service, params, headers)
        dispatcher = Stealth::Dispatcher.new(
          service: service,
          params: params,
          headers: headers
        )

        dispatcher.process
      end
    end

  end
end
