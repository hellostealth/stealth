# coding: utf-8
# frozen_string_literal: true

module Stealth
  class Errors < StandardError

    class ConfigurationError < Errors
    end

    class ReplyFormatNotSupported < Errors
    end

    class ServiceImpaired < Errors
    end

    class ServiceError < Errors
    end

    class ServiceNotRecognized < Errors
    end

    class ControllerRoutingNotImplemented < Errors
    end

    class UndefinedVariable < Errors
    end

    class RedisNotConfigured < Errors
    end

    class InvalidStateTransition < Errors
    end

    class ReplyNotFound < Errors
    end

    class UnrecognizedMessage < Errors
    end

    class FlowError < Errors
    end

    class FlowDefinitionError < Errors
    end

    class FlowTriggered < Errors
    end

    # Service errors
    class InvalidSessionID < Errors
    end

    class UserOptOut < Errors
    end

    class MessageFiltered < Errors
    end

    class UnknownServiceError < Errors
    end

    # Homophone errors
    class ReservedHomophoneUsed < Errors
    end

    class Halted < Errors
    end

  end
end
