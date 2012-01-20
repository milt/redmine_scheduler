class Notifier < ActionMailer::Base
  def newgrants_notification(user, grants)
    recipients user.email
    from "admin@redmine.org"
    subject "This is a Test 0f the EMERGENCY Broadcast System"
    body (:user => user, :grants => grants, :url_base => 'http://localhost:3000/')
  end
end
