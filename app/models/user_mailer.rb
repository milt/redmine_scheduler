class UserMailer < ActionMailer::Base
  def welcome_email()
    recipients "durosoft@gmail.edu"
    from "redmine@example.com"
    subject "This is a test of the EMERGENCY BROADCAST SYSTEM"
    sent_on Time.now
  end
end
