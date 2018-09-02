# coding: utf-8
# frozen_string_literal: true

module Stealth
  class Controller
    module Replies

      extend ActiveSupport::Concern

      included do

        class_attribute :_preprocessors, default: [:erb]
        class_attribute :_replies_path, default: [Stealth.root, 'bot', 'replies']

        def send_replies
          yaml_reply, preprocessor = action_replies

          service_reply = Stealth::ServiceReply.new(
            recipient_id: current_session_id,
            yaml_reply: yaml_reply,
            preprocessor: preprocessor,
            context: binding
          )

          for reply in service_reply.replies do
            handler = reply_handler.new(
              recipient_id: current_session_id,
              reply: reply
            )

            translated_reply = handler.send(reply.reply_type)
            client = service_client.new(reply: translated_reply)
            client.transmit

            # If this was a 'delay' type of reply, we insert the delay
            if reply.reply_type == 'delay'
              begin
                sleep_duration = Float(reply["duration"])
                sleep(sleep_duration)
              rescue ArgumentError, TypeError
                raise(ArgumentError, 'Invalid duration specified. Duration must be a float')
              end
            end
          end

          @progressed = :sent_replies
        end

        private

          def service_client
            begin
              Kernel.const_get("Stealth::Services::#{current_service.classify}::Client")
            rescue NameError
              raise(Stealth::Errors::ServiceNotRecognized, "The service '#{current_service}' was not recognized")
            end
          end

          def reply_handler
            begin
              Kernel.const_get("Stealth::Services::#{current_service.classify}::ReplyHandler")
            rescue NameError
              raise(Stealth::Errors::ServiceNotRecognized, "The service '#{current_service}' was not recognized")
            end
          end

          def replies_folder
            current_session.flow_string.underscore.pluralize
          end

          def action_replies
            reply_dir = [*self._replies_path, replies_folder]
            reply_filename = "#{current_session.state_string}.yml"
            reply_file_path = File.join(*reply_dir, reply_filename)
            selected_preprocessor = :none

            for preprocessor in self.class._preprocessors do
              selected_filepath = File.join(*reply_dir, [reply_filename, preprocessor.to_s].join('.'))
              if File.exists?(selected_filepath)
                reply_file_path = selected_filepath
                selected_preprocessor = preprocessor
                break
              end
            end

            begin
              file_contents = File.read(reply_file_path)
            rescue Errno::ENOENT
              raise(Stealth::Errors::ReplyNotFound, "Could not find a reply in #{reply_file_path}")
            end

            return file_contents, selected_preprocessor
          end

      end # instance methods

    end
  end
end
