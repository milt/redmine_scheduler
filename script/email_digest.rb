#send digest email to all users

User.active.each do |user|
  Mailer.daily_digest(user).deliver
end
