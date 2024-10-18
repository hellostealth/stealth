# frozen_string_literal: true

module Stealth
  module Intents
    INTENTS = [
      # {
      #   name: 'get_leads_count',
      #   category: 'leads_query',
      #   description: 'Get the number of leads in the system for time period',
      #   examples: ['How many leads do we have today?', 'How many leads are there?', 'How many leads are in the system overall?'],
      #   tool: {
      #     type: "function",
      #     function: {
      #       name: "get_lead_count",
      #       description: "Get leads count for provided time span",
      #       parameters: {
      #         type: "object",
      #         properties: {
      #           start_date: { type: "string", description: "The start date with time." },
      #           end_date: { type: "string", description: "The end date with time." }
      #         },
      #         required: %w[start_date end_date],
      #         additionalProperties: false
      #       },
      #     }
      #   }
      # },
    ]
  end
end
