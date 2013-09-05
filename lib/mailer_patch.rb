# Patches Redmine's Mailer model to add fun things.
module MailerPatch
  def self.included(base) # :nodoc: add the indicated methods to Issue. not sure what :nodoc: did but it is off now
    base.extend(ClassMethods)

    base.send(:include, InstanceMethods)

    # Same as typing in the class 
    base.class_eval do
      unloadable # Send unloadable so it will not be unloaded in development

        def booking_add(booking)
          @booking = booking

          mail :to => booking.coach.mail,
            :subject => "New Booking Added"
        end

        def daily_digest(user)
          @user = user
          @digest = user.journal_digest

          mail :to => user.mail,
            :subject => "Squid Daily Digest"
        end

        def poster_add_staff(poster)
          @poster = poster 

          mail :to => Group.posterstaff.first.users.map(&:mail),
            :subject => "New Poster Print Order"
        end

        def poster_add_patron(poster)
          @poster = poster

          recipients = [poster.patron_email]

          if poster.payment_type == "budget"
            recipients << poster.budget_email
          end

          mail :to => recipients,
            :subject => "Your DMC Poster Print Order"
        end
    end

  end

  module ClassMethods
      

  end

  module InstanceMethods
      
  end
end
