Steath.reply do
  if @reason == :unrecognized_message
    say "I'm sorry, I still didn't understand that."
    say "Please hold while I transfer you to a human."
  else
    say "Uh oh, something went wrong."
  end
end
