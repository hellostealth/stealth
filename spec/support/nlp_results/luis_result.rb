module TestNlpResult
  class Luis < Stealth::Nlp::Result

    ENTITY_MAP = {
      'money' => :currency, 'number' => :number, 'email' => :email,
      'percentage' => :percentage, 'Calendar.Duration' => :duration,
      'geographyV2' => :geo, 'age' => :age, 'phonenumber' => :phone,
      'ordinalV2' => :ordinal, 'url' => :url, 'dimension' => :dimension,
      'temperature' => :temp, 'keyPhrase' => :key_phrase, 'name' => :name,
      'datetimeV2' => :datetime
    }

    attr_reader :result, :intent

    def initialize(intent:, entity: :single_number_entity)
      @result = test_responses[entity]
      @intent = intent
    end

    def parsed_result
      @result
    end

    def intent_score
      rand
    end

    def raw_entities
      @result.dig('prediction', 'entities')
    end

    def entities
      return {} if raw_entities.blank?
      _entities = {}

      raw_entities.each do |type, values|
        if ENTITY_MAP[type]
          _entities[ENTITY_MAP[type]] = values
        else
          # A custom entity
          _entities[type.to_sym] = values
        end
      end

      _entities
    end

    def sentiment
      %i(positive neutral negative).sample
    end

    def sentiment_score
      rand
    end

    def present?
      parsed_result.present?
    end

    private

    def test_responses
      {
        single_number_entity: {
          "query" => "My score was 78",
          "prediction" => {
            "topIntent" => "None",
            "intents" => {
              "None" => {
                "score" => 0.170594558
              }
            },
            "entities" => {
              "keyPhrase" => [
                "score"
              ],
              "number" => [
                78
              ]
            },
            "sentiment" => {
              "label" => "neutral",
              "score" => 0.5
            }
          }
        },

        double_number_entity: {
          "query" => "Their scores were 89 and 97, respectively",
          "prediction" => {
            "topIntent" => "None",
            "intents" => {
              "None" => {
                "score" => 0.5280223
              }
            },
            "entities" => {
              "keyPhrase" => [
                "scores"
              ],
              "number" => [
                89,
                97
              ]
            },
            "sentiment" => {
              "label" => "negative",
              "score" => 0.309174955
            }
          }
        },

        triple_number_entity: {
          "query" => "Their scores were 89, 65, and 97, respectively",
          "prediction" => {
            "topIntent" => "None",
            "intents" => {
              "None" => {
                "score" => 0.6703843
              }
            },
            "entities" => {
              "keyPhrase" => [
                "scores"
              ],
              "number" => [
                89,
                65,
                97
              ]
            },
            "sentiment" => {
              "label" => "negative",
              "score" => 0.309174955
            }
          }
        },

        custom_entity: {
          "query" => "call me right away",
          "prediction" => {
            "topIntent" => "now",
            "intents" => {
              "now" => {
                "score" => 0.781227
              }
            },
            "entities" => {
              "asap" => [
                ["right away"]
              ]
            },
            "sentiment" => {
              "label" => "neutral",
              "score" => 0.5
            }
          }
        }
      }
    end

  end
end
