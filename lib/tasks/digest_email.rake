namespace :redmine_scheduler do
  namespace :email do
    desc "Email Squid digest to all subscribed users."
    task :digest_email => :environment do
      for user in User.gets_digest
        Mailer.deliver_daily_digest(user)
      end
    end
  end
end
