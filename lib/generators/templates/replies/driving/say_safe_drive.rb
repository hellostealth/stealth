Stealth.reply do
  if current_lead[:first_name].present?
    say "Hey #{current_lead[:first_name]}. Hope you had a safe drive 🚗."
  else
    say "Hope you had a safe drive 🚗."
  end
end
