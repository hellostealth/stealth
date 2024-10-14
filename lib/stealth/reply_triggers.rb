module Stealth
  module ReplyTriggers
    def trigger_reply(flow_name, state_name, service_event)
      ReplyManager.trigger_reply(flow_name, state_name, service_event)
    end

    def reply(&block)
      ReplyManager.reply(&block)
    end
  end
end
