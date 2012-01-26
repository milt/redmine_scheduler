require_dependency 'mailer'

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
            from	"Redmine Notifications <redmine@example.com>"
            subject	"This is an EMERGENCY BROADCAST SYSTEM"
            sent_on	Time.now
            body	"Issues"
        end
    end

  end

  module ClassMethods
      

  end

  module InstanceMethods
      
  end
end

# Add module to Mailer
Mailer.send(:include, MailerPatch)
