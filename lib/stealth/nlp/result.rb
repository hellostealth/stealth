# coding: utf-8
# frozen_string_literal: true

module Stealth
  module Nlp
    class Result

      attr_reader :result

      def initialize(result:)
        @result = result
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

      # :postive, :negative, :neutral
      def sentiment
        nil
      end

      def sentiment_score
        nil
      end

    end
  end
end
