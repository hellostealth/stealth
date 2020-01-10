# coding: utf-8
# frozen_string_literal: true

module Stealth
  class Controller
    module Nlp

      extend ActiveSupport::Concern

      included do
        # Memoized in order to prevent multiple requests to the NLP provider
        def perform_nlp!
          unless Stealth.config.nlp_integration.present?
            raise Stealth::Errors::ConfigurationError, "An NLP integration has not yet been configured (Stealth.config.nlp_integration)"
          end

          @nlp_result ||= begin
            nlp_client = nlp_client_klass.new
            @nlp_result = @current_message.nlp_result = nlp_client.understand(
              query: current_message.message
            )

            @nlp_result
          end
        end

        private

        def nlp_client_klass
          integration = Stealth.config.nlp_integration.to_s.titlecase
          klass = "Stealth::Nlp::#{integration}::Client"
          klass.classify.constantize
        end
      end

    end
  end
end
