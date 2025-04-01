# frozen_string_literal: true

class String

  EXCLUDED_CHARS = %w[" ' . , ! ? ( ) - _ ` ‘ ’ “ ”].freeze
  EXCLUDED_CHARS_ESC = EXCLUDED_CHARS.map { |c| "\\#{c}" }
  EXCLUDED_CHARS_RE = /#{EXCLUDED_CHARS_ESC.join('|')}/

  # Removes blank padding and double+single quotes
  def normalize
    self.upcase.strip
  end

  def without_punctuation
    self.gsub(EXCLUDED_CHARS_RE, '')
  end

end
