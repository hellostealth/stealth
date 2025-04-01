# coding: utf-8
# frozen_string_literal: true

module Stealth
  module Nlp
    class Result

      ENTITY_TYPES = %i(number currency email percentage phone age
                        url ordinal geo dimension temp datetime duration
                        key_phrase name)

      attr_reader :result

      def initialize(result:)
        @result = result
      end

      def parsed_result
        nil
      end

      def intent_id
        nil
      end

      def intent
        nil
      end

      def intent_score
        nil
      end

      def raw_entities
        {}
      end

      def entities
        {}
      end

      # :postive, :negative, :neutral
      def sentiment
        nil
      end

      def sentiment_score
        nil
      end

      def present?
        parsed_result.present?
      end

    end
  end
end
