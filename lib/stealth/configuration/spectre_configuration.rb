module Stealth
  class SpectreConfiguration
    attr_accessor :api_key, :llm_provider

    def initialize
      @api_key = nil
      @llm_provider = nil
    end
  end
end
