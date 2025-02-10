# coding: utf-8
# frozen_string_literal: true

module Stealth
  class Controller
    module Replies

      extend ActiveSupport::Concern

      included do

        # class_attribute :_preprocessors, default: [:erb]
        # class_attribute :_replies_path, default: [Stealth.root, 'bot', 'replies']

        # def send_replies(custom_reply: nil, inline: nil)
        #   service_reply = load_service_reply(
        #     custom_reply: custom_reply,
        #     inline: inline
        #   )

        #   # Determine if we start at the beginning or somewhere else
        #   reply_range = calculate_reply_range
        #   offset = reply_range.first

        #   @previous_reply = nil
        #   service_reply.replies.slice(reply_range).each_with_index do |reply, i|
        #     # Updates the lock with the current position of the reply
        #     lock_session!(
        #       session_slug: current_session.get_session,
        #       position: i + offset # Otherwise this won't account for explicit starting points
        #     )

        #     begin
        #       send_reply(reply: reply)
        #     rescue Stealth::Errors::UserOptOut => e
        #       msg = "User #{current_session_id} opted out. [#{e.message}]"
        #       service_error_dispatcher(
        #         handler_method: :handle_opt_out,
        #         error_msg: msg
        #       )
        #       return
        #     rescue Stealth::Errors::InvalidSessionID => e
        #       msg = "User #{current_session_id} has an invalid session_id. [#{e.message}]"
        #       service_error_dispatcher(
        #         handler_method: :handle_invalid_session_id,
        #         error_msg: msg
        #       )
        #       return
        #     rescue Stealth::Errors::MessageFiltered => e
        #       msg = "Message to user #{current_session_id} was filtered. [#{e.message}]"
        #       service_error_dispatcher(
        #         handler_method: :handle_message_filtered,
        #         error_msg: msg
        #       )
        #       return
        #     rescue Stealth::Errors::UnknownServiceError => e
        #       msg = "User #{current_session_id} had an unknown error. [#{e.message}]"
        #       service_error_dispatcher(
        #         handler_method: :handle_unknown_error,
        #         error_msg: msg
        #       )
        #       return
        #     end

        #     @previous_reply = reply
        #   end

        #   @progressed = :sent_replies
        # ensure
        #   release_lock!
        # end

        def send_replies
          flow = current_session.flow_string
          state = current_session.state_string
          Stealth.trigger_reply(flow, state, current_message)
        end

        def say(reply = nil, **args)
          perform_action(:transmit, reply, **args)
        end

        def delete_message(message_id)
          perform_action(:delete, { message_id: message_id })
        end

        private

        def perform_action(action, reply_content, **args)
          if args[:reply_type] == "delay"
            insert_delay(duration: args[:duration]) if args[:duration]
            @previous_reply = Stealth::Reply.new(unstructured_reply: args) # Store delay reply
            return
          end

          full_reply = args.merge(text: reply_content)
          reply_instance = Stealth::Reply.new(unstructured_reply: full_reply)

          # Check if auto-inserting delays is enabled and if the previous reply was not a delay
          if Stealth.config.auto_insert_delays && !@previous_reply&.delay?
            # If it's the first reply or the previous reply wasn't a custom delay, insert a dynamic delay
            insert_delay(duration: "dynamic")
          end

          handler = reply_handler.new(
            recipient_id: current_message.sender_id,
            reply: reply_instance.reply
          )

          formatted_reply = handler.send(reply_instance.reply_type)
          client = service_client.new(reply: formatted_reply, **service_args(**args))
          client.public_send(action)

          log_reply(reply_instance, handler) if Stealth.config.transcript_logging

          @previous_reply = reply_instance
        end


        def service_args(**args)
          case current_service
            when 'slack'
            return {
              thread_id: args.fetch(:thread_id, nil)
            }
          else
            {}
          end
        end

        # def voice_service?
        #   current_service.match?(/voice/)
        # end

        # def send_reply(reply:)
        #   if !reply.delay? && Stealth.config.auto_insert_delays && !voice_service?
        #     # if it's the first reply in the service_reply or the previous reply
        #     # wasn't a custom delay, then insert a delay
        #     if @previous_reply.blank? || !@previous_reply.delay?
        #       send_reply(reply: Reply.dynamic_delay)
        #     end
        #   end

        #   # Support randomized replies for text and speech replies.
        #   # We select one before handing the reply off to the driver.
        #   if reply['text'].is_a?(Array)
        #     reply['text'] = reply['text'].sample
        #   end

        #   handler = reply_handler.new(
        #     recipient_id: current_message.sender_id,
        #     reply: reply
        #   )

        #   formatted_reply = handler.send(reply.reply_type)
        #   client = service_client.new(reply: formatted_reply)
        #   client.transmit

        #   log_reply(reply, handler) if Stealth.config.transcript_logging

        #   # If this was a 'delay' type of reply, we insert the delay
        #   if reply.delay?
        #     insert_delay(duration: reply['duration'])
        #   end
        # end

        def insert_delay(duration:)
          begin
            sleep_duration = if duration == 'dynamic'
              dyn_duration = dynamic_delay(previous_reply: @previous_reply)

              Stealth.config.dynamic_delay_muliplier * dyn_duration
            else
              Float(duration)
            end

            sleep(sleep_duration)
          rescue ArgumentError, TypeError
            raise(ArgumentError, 'Invalid duration specified. Duration must be a Numeric')
          end
        end

        # def load_service_reply(custom_reply:, inline:)
        #   if inline.present?
        #     Stealth::ServiceReply.new(
        #       recipient_id: current_session_id,
        #       yaml_reply: inline,
        #       preprocessor: :none,
        #       context: nil
        #     )
        #   else
        #     yaml_reply, preprocessor = action_replies(custom_reply)

        #     Stealth::ServiceReply.new(
        #       recipient_id: current_session_id,
        #       yaml_reply: yaml_reply,
        #       preprocessor: preprocessor,
        #       context: binding
        #     )
        #   end
        # end

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

        # def replies_folder
        #   current_session.flow_string.underscore.pluralize
        # end

        # def reply_dir
        #   [*self._replies_path, replies_folder]
        # end

        # def base_reply_filename
        #   "#{current_session.state_string}.yml"
        # end

        # def reply_filenames(custom_reply_filename=nil)
        #   reply_filename = if custom_reply_filename.present?
        #     custom_reply_filename
        #   else
        #     base_reply_filename
        #   end

        #   service_filename = [reply_filename, current_service].join('+')

        #   # Service-specific filenames take precedance (returned first)
        #   [service_filename, reply_filename]
        # end

        # def find_reply_and_preprocessor(custom_reply)
        #   selected_preprocessor = :none

        #   if custom_reply.present?
        #     dir_and_file = custom_reply.rpartition(File::SEPARATOR)
        #     _dir = dir_and_file.first
        #     _file = "#{dir_and_file.last}.yml"
        #     _replies_dir = [*self._replies_path, _dir]
        #     possible_filenames = reply_filenames(_file)
        #     reply_file_path = File.join(_replies_dir, _file)
        #     service_reply_path = File.join(_replies_dir, reply_filenames(_file).first)
        #   else
        #     _replies_dir = *reply_dir
        #     possible_filenames = reply_filenames
        #     reply_file_path = File.join(_replies_dir, base_reply_filename)
        #     service_reply_path = File.join(_replies_dir, reply_filenames.first)
        #   end

        #   # Check if the service_filename exists
        #   # If so, we can skip checking for a preprocessor
        #   if File.exist?(service_reply_path)
        #     return service_reply_path, selected_preprocessor
        #   end

        #   # Cycles through possible preprocessor and variant combinations
        #   # Early returns for performance
        #   for preprocessor in self.class._preprocessors do
        #     for reply_filename in possible_filenames do
        #       selected_filepath = File.join(_replies_dir, [reply_filename, preprocessor.to_s].join('.'))
        #       if File.exist?(selected_filepath)
        #         reply_file_path = selected_filepath
        #         selected_preprocessor = preprocessor
        #         return reply_file_path, selected_preprocessor
        #       end
        #     end
        #   end

        #   return reply_file_path, selected_preprocessor
        # end

        # def action_replies(custom_reply=nil)
        #   reply_path, selected_preprocessor = find_reply_and_preprocessor(custom_reply)

        #   begin
        #     file_contents = File.read(reply_path)
        #   rescue Errno::ENOENT
        #     raise(Stealth::Errors::ReplyNotFound, "Could not find reply: '#{reply_path}'")
        #   end

        #   return file_contents, selected_preprocessor
        # end

        # def service_error_dispatcher(handler_method:, error_msg:)
        #   if self.respond_to?(handler_method, true)
        #     Stealth::Logger.l(
        #       topic: current_service,
        #       message: error_msg
        #     )
        #     self.send(handler_method)
        #   else
        #     Stealth::Logger.l(
        #       topic: :err,
        #       message: "Unhandled service exception for user #{current_session_id}. No error handler for `#{handler_method}` found."
        #     )
        #   end

        #   do_nothing
        # end

        # def calculate_reply_range
        #   # if an explicit starting point is specified, use that until the
        #   # end of the range, otherwise start at the beginning
        #   if @pos.present?
        #     (@pos..-1)
        #   else
        #     (0..-1)
        #   end
        # end

        def log_reply(reply, reply_handler)
          message = case reply.reply_type
                    when 'text'
                      if reply_handler.respond_to?(:translated_reply)
                        reply_handler.translated_reply
                      else
                        reply['text']
                      end
                    when 'speech'
                      reply['speech']
                    when 'ssml'
                      reply['ssml']
                    when 'delay'
                      '<typing indicator>'
                    else
                      "<#{reply.reply_type}>"
                    end

          Stealth::Logger.l(
            topic: current_service,
            message: "User #{current_session_id} -> Sending: #{message}"
          )

          message
        end

      end # instance methods
    end
  end
end
