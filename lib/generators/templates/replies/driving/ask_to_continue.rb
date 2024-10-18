Stealth.reply do
  if current_lead[:first_name].present?
    say(
      text: "Hey #{current_lead[:first_name]}. Hope you had a safe drive 🚗. Are you ready to continue?"
      suggestions: ["Yes", "No"]
    )
  else
    say(
      text: "Hope you had a safe drive 🚗. Are you ready to continue?"
      suggestions: ["Yes"]
    )
  end
end
