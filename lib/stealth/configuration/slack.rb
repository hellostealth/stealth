module Stealth
  class Slack
    attr_accessor :webhook_url

    def initialize
      @webhook_url = nil
    end
  end
end
