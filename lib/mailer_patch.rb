# Patches Redmine's Mailer model to add fun things.
module MailerPatch
  def self.included(base) # :nodoc: add the indicated methods to Issue. not sure what :nodoc: did but it is off now
    base.extend(ClassMethods)

    base.send(:include, InstanceMethods)

    # Same as typing in the class 
    base.class_eval do
      unloadable # Send unloadable so it will not be unloaded in development

        def booking_add(booking)
            recipients	booking.timeslot.issue.assigned_to.mail
            from	"DMC Lab Coach Notifier <notification@redmine.com>"
            subject	"You have a Lab Coach Signup!"
            sent_on	Time.now
            body	("Booking scheduled with " + booking.name + " on " + booking.apt_time.strftime("%m/%d/%Y at %I:%M:%S %p") + "\nYou can contact this patron at " + booking.phone + " or " + booking.email + "\n\nProject Description:\n" + booking.project_desc + "\n\n\n\n*Do Not Reply to this Email\nThis email is an auto-generated message.  Replies to automated messages are not monitored.")
        end

        def daily_digest(user)
          recipients user.mail
          from "Squid Digest <digitalmedia@jhu.edu>"
          subject 'Squid Daily Digest'
          sent_on Time.now
          body :user => user,
               :digest => user.journal_digest
          render_multipart('digest', body)
        end
    end

  end

  module ClassMethods
      

  end

  module InstanceMethods
      
  end
end

