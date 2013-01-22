# Patches Redmine's IssueObserver
module IssueObserverPatch
  def self.included(base) # :nodoc:
    base.extend(ClassMethods)

    base.send(:include, InstanceMethods)

    # Same as typing in the class 
    base.class_eval do
      unloadable # Send unloadable so it will not be unloaded in development
      attr_accessor :send_notification
      def after_create(issue)
        if self.send_notification && (issue.project.suppress_email == false)
          (issue.recipients + issue.watcher_recipients).uniq.each do |recipient|
            Mailer.deliver_issue_add(issue, recipient)
          end
        end
      clear_notification
      end

      # Wrap send_notification so it defaults to true, when it's nil
      def send_notification
        return true if @send_notification.nil?
        return @send_notification
      end

      private

      # Need to clear the notification setting after each usage otherwise it might be cached
      def clear_notification
        @send_notification = true
      end
    end

  end

  module ClassMethods

  end

  module InstanceMethods

  end
end

