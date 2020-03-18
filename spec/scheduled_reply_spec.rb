# frozen_string_literal: true

require 'spec_helper'

describe "Stealth::ScheduledReplyJob" do

  let(:scheduled_reply_job) { Stealth::ScheduledReplyJob.new }

  it "should instantiate BotController with service_message, set flow and state, and route" do
    service_msg_double = double('service_message')
    expect(Stealth::ServiceMessage).to receive(:new).with(service: 'twilio').and_return(service_msg_double)
    expect(service_msg_double).to receive(:sender_id=).with('+18885551212')
    expect(service_msg_double).to receive(:target_id=).with('33322')

    bot_controller_double = double('bot_controller')
    expect(BotController).to receive(:new).with(service_message: service_msg_double).and_return(bot_controller_double)
    expect(bot_controller_double).to receive(:step_to).with(flow: 'my_flow', state: 'say_hi')

    scheduled_reply_job = Stealth::ScheduledReplyJob.new
    scheduled_reply_job.perform('twilio', '+18885551212', 'my_flow', 'say_hi', '33322')
  end

end
