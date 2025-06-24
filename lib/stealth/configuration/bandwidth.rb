module Stealth
  class Bandwidth
    attr_accessor :account_id, :api_username, :api_password, :application_id

    def initialize
      @account_id = nil
      @api_username = nil
      @api_password = nil
      @application_id = nil
    end
  end
end
