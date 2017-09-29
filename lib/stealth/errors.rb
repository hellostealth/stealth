# coding: utf-8
# frozen_string_literal: true

module Stealth
  class Errors < StandardError

    class ReplyFormatNotSupported < Errors
    end

    class ServiceImpaired < Errors
    end

    class ServiceNotRecognized < Errors
    end

  end
end
