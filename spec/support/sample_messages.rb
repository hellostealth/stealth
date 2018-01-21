# coding: utf-8
# frozen_string_literal: true

class SampleMessage

  def initialize(service:)
    @service = service
    @base_message = Stealth::ServiceMessage.new(service: @service)
    @base_message.sender_id = sender_id
    @base_message.timestamp = timestamp
    @base_message
  end

  def message_with_text
    @base_message.message = message
    @base_message
  end

  def message_with_payload
    @base_message.payload = payload
    @base_message
  end

  def message_with_location
    @base_message.location = location
    @base_message
  end

  def message_with_attachments
    @base_message.attachments = attachments
    @base_message
  end

  private

    def sender_id
      if @service == 'twilio'
        '+15554561212'
      else
        "8b3e0a3c-62f1-401e-8b0f-615c9d256b1f"
      end
    end

    def timestamp
      Time.now
    end

    def message
      "Hello World!"
    end

    def payload
      "some_payload"
    end

    def location
      { lat: '42.323724' , lng: '-83.047543' }
    end

    def attachments
      [ { type: 'image', url: 'https://domain.none/image.jpg' } ]
    end

    def referral
      {}
    end

end
