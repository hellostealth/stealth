# coding: utf-8
# frozen_string_literal: true

module Stealth
  module Services
    module Facebook

      class ReplyHandler < Stealth::Services::BaseReplyHandler

        attr_reader :recipient_id, :reply

        def initialize(recipient_id:, reply:)
          @recipient_id = recipient_id
          @reply = reply
        end

        def text
          check_if_arguments_are_valid!(
            suggestions: reply['suggestions'],
            buttons: reply['buttons']
          )

          template = unstructured_template
          template['message']['text'] = reply['text']

          if reply['suggestions'].present?
            fb_suggestions = generate_suggestions(suggestions: reply['suggestions'])
            template["message"]["quick_replies"] = fb_suggestions
          end

          if reply['buttons'].present?
            fb_buttons = generate_buttons(buttons: reply['buttons'])
            template["message"]["buttons"] = fb_suggestions
          end

          template
        end

        def image
          check_if_arguments_are_valid!(
            suggestions: reply['suggestions'],
            buttons: reply['buttons']
          )

          template = unstructured_template
          attachment = attachment_template(
            attachment_type: 'image',
            attachment_url: reply['image_url']
          )
          template['message']['attachment'] = attachment

          if reply['suggestions'].present?
            fb_suggestions = generate_suggestions(suggestions: reply['suggestions'])
            template["message"]["quick_replies"] = fb_suggestions
          end

          if reply['buttons'].present?
            fb_buttons = generate_buttons(buttons: reply['buttons'])
            template["message"]["buttons"] = fb_suggestions
          end

          template
        end

        def audio
          check_if_arguments_are_valid!(
            suggestions: reply['suggestions'],
            buttons: reply['buttons']
          )

          template = unstructured_template
          attachment = attachment_template(
            attachment_type: 'audio',
            attachment_url: reply['audio_url']
          )
          template['message']['attachment'] = attachment

          if reply['suggestions'].present?
            fb_suggestions = generate_suggestions(suggestions: reply['suggestions'])
            template["message"]["quick_replies"] = fb_suggestions
          end

          if reply['buttons'].present?
            fb_buttons = generate_buttons(buttons: reply['buttons'])
            template["message"]["buttons"] = fb_suggestions
          end

          template
        end

        def video
          check_if_arguments_are_valid!(
            suggestions: reply['suggestions'],
            buttons: reply['buttons']
          )

          template = unstructured_template
          attachment = attachment_template(
            attachment_type: 'video',
            attachment_url: reply['video_url']
          )
          template['message']['attachment'] = attachment

          if reply['suggestions'].present?
            fb_suggestions = generate_suggestions(suggestions: reply['suggestions'])
            template["message"]["quick_replies"] = fb_suggestions
          end

          if reply['buttons'].present?
            fb_buttons = generate_buttons(buttons: reply['buttons'])
            template["message"]["buttons"] = fb_suggestions
          end

          template
        end

        def file
          check_if_arguments_are_valid!(
            suggestions: reply['suggestions'],
            buttons: reply['buttons']
          )

          template = unstructured_template
          attachment = attachment_template(
            attachment_type: 'file',
            attachment_url: reply['file_url']
          )
          template['message']['attachment'] = attachment

          if reply['suggestions'].present?
            fb_suggestions = generate_suggestions(suggestions: reply['suggestions'])
            template["message"]["quick_replies"] = fb_suggestions
          end

          if reply['buttons'].present?
            fb_buttons = generate_buttons(buttons: reply['buttons'])
            template["message"]["buttons"] = fb_suggestions
          end

          template
        end

        def cards
          template = card_template(
            sharable: reply["details"]["sharable"],
            aspect_ratio: reply["details"]["aspect_ratio"]
          )

          fb_elements = generate_card_elements(elements: reply["details"]["elements"])
          template["message"]["attachments"]["payload"]["elements"] = fb_elements

          template
        end

        def list
          template = list_template(
            top_element_style: reply["details"]["top_element_style"]
          )

          fb_elements = generate_list_elements(elements: reply["details"]["elements"])
          template["message"]["attachments"]["payload"]["elements"] = fb_elements

          if reply["details"]["buttons"].present?
            if reply["details"]["buttons"].size > 1
              raise(ArgumentError, "Facebook lists support a single button attached to the list itsef.")
            end

            template["message"]["attachments"]["payload"]["buttons"] = generate_buttons(buttons: reply["details"]["buttons"])
          end

          template
        end

        def mark_seen
          sender_action_template(action: 'mark_seen')
        end

        def enable_typing_indicator
          sender_action_template(action: 'typing_on')
        end

        def disable_typing_indicator
          sender_action_template(action: 'typing_off')
        end

        private

          def unstructured_template
            {
              "recipient" => {
                "id" => recipient_id
              },
              "message" => { }
            }
          end

          def card_template(sharable: nil, aspect_ratio: nil)
            template = {
              "recipient" => {
                "id" => recipient_id
              },
              "message" => {
                "type" => "template",
                "payload" => {
                  "template_type" => "generic",
                  "elements" => []
                }
              }
            }

            if sharable.present?
              template["message"]["payload"]["sharable"] = sharable
            end

            if aspect_ratio.present?
              template["message"]["payload"]["image_aspect_ratio"] = aspect_ratio
            end

            template
          end

          def list_template(top_element_style: nil, buttons: [])
            template = {
              "recipient" => {
                "id" => recipient_id
              },
              "message" => {
                "type" => "template",
                "payload" => {
                  "template_type" => "list",
                  "elements" => []
                }
              }
            }

            if top_element_style.present?
              unless ['large', 'compact'].include?(top_element_style)
                raise(ArgumentError, "Facebook list replies only support 'large' or 'compact' as the top_element_style.")
              end

              template["message"]["payload"]["top_element_style"] = top_element_style
            end

            if buttons.present?
              unless buttons.size > 1
                raise(ArgumentError, "Facebook lists only support a single button in the top element.")
              end

              template["message"]["payload"]["buttons"] = aspect_ratio
            end

            template
          end

          def element_template(element_type:, element:)
            unless element["text"].present?
              raise(ArgumentError, "Facebook card and list elements must have a 'text' attribute.")
            end

            template = {
              "title" => element["title"]
            }

            if element["subtitle"].present?
              template["subtitle"] = element["subtitle"]
            end

            if element["image_url"].present?
              template["image_url"] = element["image_url"]
            end

            if element["default_action"].present?
              default_action = generate_default_action(action_params: element["default_action"])
              template["default_action"] = default_action
            end

            if element["buttons"].present?
              if element_type == 'card' && element["buttons"].size > 3
                raise(ArgumentError, "Facebook card elements only support 3 buttons.")
              end

              if element_type == 'list' && element["buttons"].size > 1
                raise(ArgumentError, "Facebook list elements only support 1 button.")
              end

              fb_buttons = generate_buttons(buttons: element["buttons"])
              template["buttons"] = fb_buttons
            end

            template
          end

          def attachment_template(attachment_type:, attachment_url:)
            {
              "type" => attachment_type,
              "payload" => {
                "url" => attachment_url
              }
            }
          end

          def sender_action_template(action:)
            {
              "recipient" => {
                "id" => recipient_id
              },
              "sender_action" => {
                "text" => action
              }
            }
          end

          def generate_card_elements(elements:)
            if elements.size > 10
              raise(ArgumentError, "Facebook cards can have at most 10 cards.")
            end

            fb_elements = elements.collect do |element|
              element_template(element_type: 'card', element: element)
            end

            fb_elements
          end

          def generate_list_elements(elements:)
            if elements.size < 2 || elements.size > 4
              raise(ArgumentError, "Facebook lists must have 2-4 elements.")
            end

            fb_elements = elements.collect do |element|
              element_template(element_type: 'list', element: element)
            end

            fb_elements
          end

          def generate_suggestions(suggestions:)
            quick_replies = suggestions.collect do |suggestion|
              # If the user selected a location-type button, no other info needed
              if suggestion["type"] == 'location'
                quick_reply = { "content_type" => "location" }

              # Facebook only supports these two types for now
              else
                quick_reply = {
                  "content_type" => "text",
                  "title" => suggestion["text"]
                }

                if suggestion["payload"].present?
                  quick_reply["payload"] = suggestion["payload"]
                else
                  quick_reply["payload"] = suggestion["text"]
                end

                if suggestion["image_url"].present?
                  quick_reply["image_url"] = suggestion["image_url"]
                end
              end

              quick_reply
            end

            quick_replies
          end

          # Requires adding support for Buy, Log In, Log Out, and Share button types
          def generate_buttons(buttons:)
            fb_buttons = buttons.collect do |button|
              case button['type']
              when 'url'
                button = {
                  "type" => "web_url",
                  "url" => button["url"],
                  "title" => button["text"]
                }

                if button["webview_height"].present?
                  button["webview_height_ratio"] = button["webview_height"]
                end

                button

              when 'payload'
                button = {
                  "type" => "postback",
                  "payload" => button["payload"],
                  "title" => button["text"]
                }

              when 'call'
                button = {
                  "type" => "phone_number",
                  "payload" => button["phone_number"],
                  "title" => button["text"]
                }

              else
                raise(Stealth::Errors::ServiceImpaired, "Sorry, we don't yet support #{button["type"]} buttons yet!")
              end

              button
            end

            fb_buttons
          end

          def generate_default_action(action_params:)
            default_action = {
              "type" => "web_url",
              "url" => action_params["url"]
            }

            if action_params["webview_height"].present?
              action_params["webview_height_ratio"] = action_params["webview_height"]
            end

            default_action
          end

          def check_if_arguments_are_valid!(suggestions:, buttons:)
            if !suggestions.empty? && !buttons.empty?
              raise(ArgumentError, "A reply cannot have buttons and suggestions!")
            end
          end
      end

    end
  end
end
