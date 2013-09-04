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
    end

  end

  module ClassMethods
      

  end

  module InstanceMethods
      
  end
end
