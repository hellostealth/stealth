module CatchAllHelper
  def set_catch_all_reason
    @reason = case current_message.catch_all_reason[:err].to_s
    when 'Stealth::Errors::UnrecognizedMessage'
      Message.log_catch_all
      :unrecognized_message
    else
      :system_error
    end
  end
end
