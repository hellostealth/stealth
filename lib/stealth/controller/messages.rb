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

        # Hash for message and lambda pairs. If the message is matched, the
        # lambda will be called.
        #
        # Example: {
        #   "100k" => proc { step_back }, "200k" => proc { step_to flow :hello }
        # }
        def handle_message(message_tuples)
          match = 0xdeadbeef # dummy value since nils are used
          message_tuples.keys.each_with_index do |msg, i|
            # Before checking content, match against our ordinals
            if message_matches_ordinal?(msg, i)
              match = msg
              break
            end

            # intent detection
            if msg.is_a?(Symbol)
              perform_nlp! unless nlp_result.present?

              if intent_matched?(msg)
                match = msg
                break
              else
                next
              end
            end

            # custom mismatch handler; any nil key results in a match
            if msg.nil?
              match = msg
              break
            end

            if message_matches?(msg)
              match = msg
              break
            end
          end

          if match != 0xdeadbeef
            instance_eval(&message_tuples[match])
          else
            handle_mismatch(true)
          end
        end

        # Matches the message or the oridinal value entered (via SMS)
        # Ignores case and strips leading and trailing whitespace before matching.
        def get_match(messages, raise_on_mismatch: true, fuzzy_match: true)
          messages.each_with_index do |msg, i|
            # Before checking content, match against our ordinals
            if message_matches_ordinal?(msg, i)
              return msg
            end

            # entity detection
            if msg.is_a?(Symbol)
              perform_nlp! unless nlp_result.present?

              if match = entity_matched?(msg, fuzzy_match)
                return match
              else
                next
              end
            end

            # multi-entity detection
            if msg.is_a?(Array)
              perform_nlp! unless nlp_result.present?

              if match = entities_matched?(msg, fuzzy_match)
                return match
              else
                next
              end
            end

            if message_matches?(msg)
              return msg
            end
          end

          handle_mismatch(raise_on_mismatch)
        end

        private

        def handle_mismatch(raise_on_mismatch)
          log_nlp_result

          if raise_on_mismatch
            raise(
              Stealth::Errors::MessageNotRecognized,
              "The reply '#{current_message.message}' was not recognized."
            )
          else
            current_message.message
          end
        end

        def message_matches_ordinal?(msg, pos)
          normalized_msg == ALPHA_ORDINALS[pos]
        end

        def message_matches?(msg)
          normalized_msg == msg.upcase
        end

        def intent_matched?(intent)
          nlp_result.intent == intent
        end

        def entity_matched?(entity, fuzzy_match)
          if nlp_result.entities.has_key?(entity)
            match_count = nlp_result.entities[entity].size
            if match_count > 1 && !fuzzy_match
              log_nlp_result

              raise(
                Stealth::Errors::MessageNotRecognized,
                "Encountered #{match_count} entity matches of type #{entity.inspect} and expected 1. To allow, set fuzzy_match to true."
              )
            else
              # For single entity matches, just return the value
              # rather than a single-element array
              nlp_result.entities[entity].first
            end
          end
        end

        def entities_matched?(entities, fuzzy_match)
          nlp_entities = nlp_result.entities.deep_dup
          results = []

          entities.each do |entity|
            # If we run out of matches for the entity type
            # (or never had any to begin with)
            return false if nlp_entities[entity].blank?

            results << nlp_entities[entity].shift
          end

          # Check for leftover entities for the types we were looking for
          unless fuzzy_match
            entities.each do |entity|
              unless nlp_entities[entity].blank?
                log_nlp_result
                leftover_count = nlp_entities[entity].size
                raise(
                  Stealth::Errors::MessageNotRecognized,
                  "Encountered #{leftover_count} additional entity matches of type #{entity.inspect} for match #{entities.inspect}. To allow, set fuzzy_match to true."
                )
              end
            end
          end

          results
        end

        def log_nlp_result
          # Log the results from the nlp_result if NLP was performed
          if nlp_result.present?
            Stealth::Logger.l(
              topic: :nlp,
              message: "User #{current_session_id} -> NLP Result: #{nlp_result.parsed_result.inspect}"
            )
          end
        end

      end
    end
  end
end
