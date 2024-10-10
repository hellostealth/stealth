# frozen_string_literal: true

require 'spectre/prompt'

module Stealth
  class Controller
    module IntentClassifier
      extend ActiveSupport::Concern

      included do
        def get_intent(message, categories: [])
          return nil if message.nil?

          intents = self.class.get_intents_file
          intents = if categories.present?
                      intents.select { |intent| categories.include?(intent[:category]) }
                    end

          system_prompt = Spectre::Prompt.render(template: 'intent_classifier/system', locals: { intents: intents })
          user_prompt = Spectre::Prompt.render(template: 'intent_classifier/user', locals: { message: message })
          messages = [{ role: 'system', content: system_prompt }, { role: 'user', content: user_prompt }]
          json_schema = {
            name: "intent_response",
            schema: {
              type: "object",
              properties: {
                intent: { type: "string", description: "The name of the identified intent from the conversation message." }
              },
              required: ["intent"],
              additionalProperties: false
            },
            strict: true
          }

          response = Spectre::provider_module::Completions.create(messages: messages, json_schema: json_schema)
          response_intent = JSON.parse(response[:content])['intent']
          if response_intent.present?
            { intent: response_intent, tool: intents.select{ |intent| intent[:name] == response_intent }.first[:tool] }
          end
        end

        private

        def self.get_intents_file
          file_path = Pathname.new(Stealth.root).join('stealth', 'intents.rb')

          raise "Intents file not found: #{file_path}" unless File.exist?(file_path)

          load file_path

          Stealth::Intents::INTENTS
        rescue LoadError => e
          raise "Error loading Intents file #{file_path}: #{e.message}"
        end
      end

    end
  end
end
