module Stealth
  module Version
    def self.version
      File.read(File.join(File.dirname(__FILE__), '../..', 'VERSION')).strip
    end
  end

  VERSION = Version.version
end
