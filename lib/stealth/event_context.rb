module Stealth
  class EventContext
    def initialize(controller)
      @controller = controller
    end

    def current_message
      @controller.current_message
    end

    def current_service
      @controller.current_service
    end

    def current_session_id
      @controller.current_session_id
    end

    def current_session
      @controller.current_session
    end

    def has_location?
      @controller.has_location?
    end

    def has_attachments?
      @controller.has_attachments?
    end
  end
end
