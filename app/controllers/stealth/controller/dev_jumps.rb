# coding: utf-8
# frozen_string_literal: true

module Stealth
  class Controller
    module DevJumps

      DEV_JUMP_REGEX = /\A\/(.*)\/(.*)\z|\A\/\/(.*)\z|\A\/(.*)\z/

      extend ActiveSupport::Concern

      included do
        private

        def dev_jump_detected?
          if Stealth.env.development?
            if current_message.message&.match(DEV_JUMP_REGEX)
              handle_dev_jump
              return true
            end
          end

          false
        end

        def handle_dev_jump
          _, flow, state = current_message.message.split('/')
          flow = nil if flow.blank?

          Stealth::Logger.l(
            topic: 'dev_jump',
            message: "Dev Jump detected: Flow: #{flow.inspect} State: #{state.inspect}"
          )

          step_to flow: flow, state: state
        end
      end

    end
  end
end