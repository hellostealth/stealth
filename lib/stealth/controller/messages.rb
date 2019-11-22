# frozen_string_literal: true

module Stealth
  class Controller
    module Messages
      extend ActiveSupport::Concern

      included do
        unless defined?(ALPHA_ORDINALS)
          ALPHA_ORDINALS = ('A'..'Z').to_a.freeze
        end

        def normalized_msg
          current_message.message&.upcase&.strip
        end

        # Hash for response and lambda pairs. If the response is matched, the
        # lambda will be called.
        #
        # Example: {
        #   "100k" => proc { step_back }, "200k" => proc { step_to flow :hello }
        # }
        def handle_response(response_tuples)
          matched = get_match(response_tuples.keys)

          instance_eval(&response_tuples[matched])
        end

        # Matches the typed reponse or the oridinal value entered (via SMS)
        # Ignores case and strips leading and trailing whitespace before matching.
        def get_match(responses, raise_on_mismatch: true)
          responses.each_with_index do |resp, i|
            # Intent detction
            if resp.is_a?(Symbol)

            end

            if normalized_msg == resp.upcase || normalized_msg == ALPHA_ORDINALS[i]
              return resp
            end
          end

          if raise_on_mismatch
            raise(
              StandardError,
              "The reply '#{current_message.message}' was not recognized."
            )
          else
            current_message.message
          end
        end

      end
    end
  end
end
