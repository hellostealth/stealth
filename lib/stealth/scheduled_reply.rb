# coding: utf-8
# frozen_string_literal: true

module Stealth

  class ScheduledReplyJob < Stealth::Jobs
    sidekiq_options queue: :webhooks, retry: false

    def perform(service, user_id, flow, state)
      service_message = ServiceMessage.new(service: service)
      service_message.sender_id = user_id
      controller = BotController.new(service_message: service_message)
      controller.update_session_to(flow: flow, state: state)
      controller.route
    end
  end

end
