# coding: utf-8
# frozen_string_literal: true

module Stealth
  class Controller
    module Llm

      extend ActiveSupport::Concern

      included do
        def perform_llm!
          Stealth::Logger.l(
            topic: :llm,
            message: "User #{current_session_id} -> Querying LLM for intent detection."
          )

          @llm_result ||= begin
            llm_response = get_intent(current_message.message)
            current_message.llm_result = llm_response

            if llm_response.blank?
              Stealth::Logger.l(
                topic: :llm,
                message: "User #{current_session_id} -> No intent detected."
              )
              return nil
            end

            intent_name = llm_response[:intent].to_sym
            Stealth::Logger.l(
              topic: :llm,
              message: "User #{current_session_id} -> LLM resulting intent: #{intent_name}."
            )

            llm_response
          rescue StandardError => e
            Stealth::Logger.l(
              topic: :llm,
              message: "User #{current_session_id} -> LLM API Error: #{e.message}"
            )
            nil
          end
        end

        def redirect_to_llm_intent
          intent = current_message.llm_result&.dig(:intent)

          unless intent.present?
            error = Stealth::Errors::UnrecognizedMessage.new("Missing intent in LLM result")
            return run_unrecognized_message(err: error)
          end

          step_to(flow: intent.to_sym)
        end

      end

    end
  end
end
