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

          service_reply.replies.each_with_index do |reply, i|
            # Support randomized replies for text and speech replies.
            # We select one before handing the reply off to the driver.
            if reply['text'].is_a?(Array)
              reply['text'] = reply['text'].sample
            end

            handler = reply_handler.new(
              recipient_id: current_message.sender_id,
              reply: reply
            )

            translated_reply = handler.send(reply.reply_type)
            client = service_client.new(reply: translated_reply)
            client.transmit

            # If this was a 'delay' type of reply, we insert the delay
            if reply.reply_type == 'delay'
              begin
                if reply['duration'] == 'dynamic'
                  m = Stealth.config.dynamic_delay_muliplier
                  duration = dynamic_delay(
                    service_replies: service_reply.replies,
                    position: i
                  )

                  sleep_duration = Stealth.config.dynamic_delay_muliplier * duration
                else
                  sleep_duration = Float(reply['duration'])
                end

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

          def reply_dir
            [*self._replies_path, replies_folder]
          end

          def base_reply_filename
            "#{current_session.state_string}.yml"
          end

          def reply_filenames
            service_filename = [base_reply_filename, current_service].join('+')

            # Service-specific filenames take precedance (returned first)
            [service_filename, base_reply_filename]
          end

          def find_reply_and_preprocessor
            selected_preprocessor = :none
            reply_file_path = File.join(*reply_dir, base_reply_filename)
            service_reply_path = File.join(*reply_dir, reply_filenames.first)

            # Check if the service_filename exists
            # If so, we can skip checking for a preprocessor
            if File.exist?(service_reply_path)
              return service_reply_path, selected_preprocessor
            end

            # Cycles through possible preprocessor and variant combinations
            # Early returns for performance
            for preprocessor in self.class._preprocessors do
              for reply_filename in reply_filenames do
                selected_filepath = File.join(*reply_dir, [reply_filename, preprocessor.to_s].join('.'))
                if File.exist?(selected_filepath)
                  reply_file_path = selected_filepath
                  selected_preprocessor = preprocessor
                  return reply_file_path, selected_preprocessor
                end
              end
            end

            return reply_file_path, selected_preprocessor
          end

          def action_replies
            reply_file_path, selected_preprocessor = find_reply_and_preprocessor

            begin
              file_contents = File.read(reply_file_path)
            rescue Errno::ENOENT
              raise(Stealth::Errors::ReplyNotFound, "Could not find a reply in #{reply_dir}")
            end

            return file_contents, selected_preprocessor
          end

      end # instance methods

    end
  end
end
