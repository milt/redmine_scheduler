# Patches Redmine's Time Entries
module TimeEntryPatch
  def self.included(base) # :nodoc:
    base.extend(ClassMethods)

    base.send(:include, InstanceMethods)

    # Same as typing in the class 
    base.class_eval do
      unloadable # Send unloadable so it will not be unloaded in development
      belongs_to :timesheet
      scope :foruser, lambda {|u| { :conditions => { :user_id => u.id } } }
      scope :from_date, lambda {|d| { :conditions => ["spent_on >= ?", d] } }
      scope :until_date, lambda {|d| { :conditions => ["spent_on <= ?", d] } }
      scope :ondate, lambda {|d| { :conditions => ["spent_on = ?", d] } }
      scope :on_tweek, lambda {|d| { :conditions => ["tweek = ?", d] } }
      scope :on_tyear, lambda {|d| { :conditions => ["tyear = ?", d] } }
      scope :sort_by_date, :order => "spent_on ASC"
      scope :last_day, lambda { { :conditions => ["updated_on >= ?", DateTime.now - 24.hours] } }
      validate :cannot_create_if_timesheet_exists, on: :create
      validate :locked_when_attached_to_timesheet, on: :update

      
      def locked_when_attached_to_timesheet
        errors.add_to_base("Cannot edit because this time entry is attached to timesheet #{self.timesheet_id}.") if
          Timesheet.for_user(self.user).weekof_on(self.spent_on.monday).is_submitted.present?
      end

      def cannot_create_if_timesheet_exists
        errors.add_to_base("Cannot create time entry because there is already a timesheet submitted for the given week: #{Timesheet.for_user(self.user).weekof_on(self.spent_on.monday).is_submitted.first.id}") if
          Timesheet.for_user(self.user).weekof_on(self.spent_on.monday).is_submitted.present?  
      end

      def self.unpaid
        where(timesheet_id: nil)
      end

    end

  end

  module ClassMethods

  end

  module InstanceMethods

    def week_spent_on
      "Week Beginning " + self.spent_on.beginning_of_week.strftime('%b %d, %Y')
    end

    def cweek
      self.spent_on.cweek
    end
  end
end
