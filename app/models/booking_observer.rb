class BookingObserver < ActiveRecord::Observer
    attr_accessor :send_notification
    
    def after_create(booking)
        if self.send_notification
            Mailer.booking_add(booking).deliver #if Setting.notified_events.include?
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
