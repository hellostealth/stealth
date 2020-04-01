# frozen_string_literal: true

class String

  # Removes blank padding and double+single quotes
  def normalize
    self.upcase.gsub(/\"|\'/, '').strip
  end

end
