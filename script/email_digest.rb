#send digest email to all users

Users.active.each do |user|
  Mailer.daily_digest(user).deliver
end
