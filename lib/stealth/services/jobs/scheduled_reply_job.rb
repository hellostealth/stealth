# coding: utf-8
# frozen_string_literal: true

module Stealth
  module Services

    # class ScheduledReplyJob < Stealth::Jobs
    #   sidekiq_options queue: :stealth_replies, retry: false

    #   def perform(service, user_id, flow, state, target_id=nil)
    #     service_message = ServiceMessage.new(service: service)
    #     service_message.sender_id = user_id
    #     service_message.target_id = target_id
    #     controller = BotController.new(service_message: service_message)
    #     controller.step_to(flow: flow, state: state)
    #   end
    # end

    class ScheduledReplyJob < Stealth::Jobs
      sidekiq_options queue: :stealth_replies, retry: false

      def perform(service, user_id, flow, state, target_id=nil)
        service_event = ServiceEvent.new(service: service)
        service_event.sender_id = user_id
        service_event.target_id = target_id

        controller = Stealth::Controller.new(service_event: service_event)
        controller.step_to(flow: flow, state: state)
      end
    end
  end

end
