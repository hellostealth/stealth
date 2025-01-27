module Stealth
  class SpectreConfiguration
    attr_accessor :api_key, :llm_provider, :ollama_host

    def initialize
      @api_key = nil
      @llm_provider = nil
      @ollama_host = nil
    end
  end
end
