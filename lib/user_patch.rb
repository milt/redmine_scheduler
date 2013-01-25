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

    end

  end

  module ClassMethods

  end

  module InstanceMethods

    def journal_digest
      owned_issues = Issue.foruser(self).updated_in_last_day
      watched_issues = Issue.watched_by(self).updated_in_last_day

      owned_hash = {}
      watched_hash = {}

      owned_issues.map {|i| owned_hash[i] = Journal.last_day.from_issue(i) + i.time_entries.reduce([]) {|journals,time_entry| journals + Journal.last_day.from_time_entry(time_entry)}}
      watched_issues.map {|i| watched_hash[i] = Journal.last_day.from_issue(i) + i.time_entries.reduce([]) {|journals,time_entry| journals + Journal.last_day.from_time_entry(time_entry)}}

      return { :owned => owned_hash,
               :watched => watched_hash
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

