# coding: utf-8
# frozen_string_literal: true

require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Stealth::ServiceReply" do

  describe "nested reply with ERB" do
    let(:recipient_id) { "8b3e0a3c-62f1-401e-8b0f-615c9d256b1f" }
    let(:yaml_reply) { File.read(File.join(File.dirname(__FILE__), 'replies', 'nested_reply_with_erb.yml')) }

    it "should load all the replies" do
      first_name = "Presley"

      service_reply = Stealth::ServiceReply.new(
        recipient_id: recipient_id,
        yaml_reply: yaml_reply,
        context: binding
      )

      expect(service_reply.replies.size).to eq 5
    end

    it "should raise Stealth::Errors::UndefinedVariable when local variable is not available" do
      expect {
        service_reply = Stealth::ServiceReply.new(
          recipient_id: recipient_id,
          yaml_reply: yaml_reply,
          context: binding
        )
      }.to raise_error(Stealth::Errors::UndefinedVariable)
    end
  end

end
