Stealth.reply do
  if @reason == :unrecognized_message
    say "I'm sorry, I didn't understand that."
  else
    say "Uh oh, something went wrong."
  end
end
