# coding: utf-8
# frozen_string_literal: true

require 'stealth/services/facebook/client'

module Stealth
  module Services
    module Facebook

      class Setup

        class << self
          def trigger
            set_greeting_text
            set_persistent_menu
          end

          private

            def set_greeting_text

            end

            def set_persistent_menu

            end

        end
      end

    end
  end
end
