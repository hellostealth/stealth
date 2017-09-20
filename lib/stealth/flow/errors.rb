module Stealth
  module Flow
    class Error < StandardError; end

    class TransitionHalted < Error

      attr_reader :halted_because

      def initialize(msg = nil)
        @halted_because = msg
        super msg
      end

    end

    class NoTransitionAllowed < Error; end

    class StealthFlowError < Error; end

    class StealthFlowDefinitionError < Error; end
  end
end
