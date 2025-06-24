module Stealth
  class SpectreConfiguration
    attr_accessor :default_llm_provider, :openai_api_key, :ollama_api_key, :ollama_host

    def initialize
      @default_llm_provider = nil
      @openai_api_key = nil
      @ollama_host = nil
      @ollama_api_key = nil
    end
  end
end
