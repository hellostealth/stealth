module Stealth
  class Errors < StandardError

    class ReplyFormatNotSupported < Errors
    end

    class ServiceImpaired < Errors
    end

  end
end
