class UserMailer < ActionMailer::Base
  default :from => "redmine@example.com"

  def welcome_email()
    @user = "milt@jhu.edu
    @url = "http://example.com"
    mail(:to => user, :subject => "This is a Test of the Emergency BROADCAST System")
  end

end
