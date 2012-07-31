# Patches Redmine's Time Entries
module TimeEntryPatch
  def self.included(base) # :nodoc:
    base.extend(ClassMethods)

    base.send(:include, InstanceMethods)

    # Same as typing in the class 
    base.class_eval do
      unloadable # Send unloadable so it will not be unloaded in development
      belongs_to :timesheet
      named_scope :foruser, lambda {|u| { :conditions => { :user_id => u.id } } }
      named_scope :after, lambda {|d| { :conditions => ["spent_on >= ?", d] } }
      named_scope :before, lambda {|d| { :conditions => ["spent_on <= ?", d] } }
      named_scope :ondate, lambda {|d| { :conditions => ["spent_on = ?", d] } }
      named_scope :on_tweek, lambda {|d| { :conditions => ["tweek = ?", d] } }
      named_scope :on_tyear, lambda {|d| { :conditions => ["tyear = ?", d] } }
      named_scope :sort_by_date, :order => "spent_on ASC"
      # validates_each :project_id,
      #   :user_id,
      #   :issue_id,
      #   :hours,
      #   :comments,
      #   :activity_id,
      #   :spent_on,
      #   :tyear,
      #   :tmonth,
      #   :tweek,
      #   :created_on,
      #   :on => :update,
      #   :if => "timesheet_id.present?" do |model, attr, value|
      #     model.errors.add(attr, 'can not change when entry is locked to a timesheet') if value.present?
      #   end
      
    end

  end

  module ClassMethods

  end

  module InstanceMethods
    def is_locked?
      self.timesheet.present?
    end

    def is_extra?
      Timesheet.weekof_on( Date.parse("1-1-#{DateTime.now.year}").to_datetime + (self.tweek - 1).weeks).present?
    end
  end
end
