# Patches Redmine's Users dynamically.  Adds a relationship User +has_and_belongs_to_many+ Skill. 
module UserPatch
  def self.included(base) # :nodoc:
    base.extend(ClassMethods)

    base.send(:include, InstanceMethods)

    # Same as typing in the class 
    base.class_eval do
      unloadable # Send unloadable so it will not be unloaded in development
      #has_and_belongs_to_many :skills
      has_many :levels, :dependent => :destroy
      has_many :skills, :through => :levels
      has_one :wage
      has_many :repairs, :dependent => :nullify
      has_many :workgroups, :class_name => "Group",
        :foreign_key => "manager_id"
      has_many :time_entries
      has_many :timesheets
      has_many :bookings, :foreign_key => "coach_id"
      has_many :authored_bookings, :class_name => "Booking", :foreign_key => "author_id"
      scope :gets_digest, lambda { { :conditions => {:digest => true} } }
      safe_attributes 'digest'

      def self.with_skills(*skills)
        joins(:skills).where("skills.id IN (?)", skills.map(&:id))
      end

    end

  end

  module ClassMethods

  end

  module InstanceMethods

    def tasks
      Issue.foruser(self).tasks
    end

    def journal_digest
      new_issues = Issue.foruser(self).created_in_last_day.recently_updated.reject {|i| i.is_shift?}
      owned_issues = Issue.foruser(self).updated_in_last_day.recently_updated.reject {|i| i.is_shift?} - new_issues
      authored_issues = Issue.for_author(self).updated_in_last_day.recently_updated.reject {|i| i.is_shift?}
      watched_issues = Issue.watched_by(self).updated_in_last_day.recently_updated.reject {|i| i.is_shift?} - authored_issues
      repair_issues = Issue.unassigned.repairs

      owned_hash = {}
      watched_hash = {}
      new_hash = {}
      authored_hash = {}
      repair_hash = {}

      owned_issues.each {|i| owned_hash[i] = Journal.last_day.not_initial.from_issue(i).order_for_display}
      watched_issues.each {|i| watched_hash[i] = Journal.last_day.not_initial.from_issue(i).order_for_display}
      new_issues.each {|i| new_hash[i] = Journal.last_day.not_initial.from_issue(i).order_for_display}
      authored_issues.each {|i| authored_hash[i] = Journal.last_day.not_initial.from_issue(i).order_for_display}
      repair_issues.each {|i| repair_hash[i] = []}

      return { :owned => owned_hash.delete_if {|k,v| v.empty? && k.time_entries.last_day.empty?},
               :watched => watched_hash.delete_if {|k,v| v.empty? && k.time_entries.last_day.empty?},
               :new => new_hash,
               :authored => authored_hash.delete_if {|k,v| v.empty? && k.time_entries.last_day.empty?},
               :repair => repair_hash
      }
    end

    def skillcats
      (self.skills.collect {|s|s.skillcat}).uniq
    end

    def is_stustaff?
      self.groups.include?(Group.stustaff.first)
    end

    def is_prostaff?
      self.groups.include?(Group.prostaff.first)
    end

    def is_admstaff?
      self.groups.include?(Group.admstaff.first)
    end

    def timesheet_role
      case
      when self.is_stustaff?
        role = :staff
      when self.is_admstaff?
        role = :admin
      end
      return role
    end

    def analyze_time(hours)
      c = 0.0
      b = self.time_entries.sort_by_date.reverse.take_while do |m|
        c += m.hours
        c <= hours
      end
      return b
    end
    
    def get_workload(weeks_back)
      self.time_entries.sort_by_date.after(Date.today - weeks_back.weeks)
    end
    
    def get_open_slots_by_date_range(from, to)
      slots = []
      Issue.lcshift.from_date(from).until_date(to).foruser(self).each do |issue|
        slots += issue.open_slots
      end
      return slots
    end
  end
end

