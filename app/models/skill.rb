class Skill < ActiveRecord::Base
  has_and_belongs_to_many :users, :uniq => true
  belongs_to :skillcat
  validates_uniqueness_of :name
  validates_presence_of :name, :skillcat_id
  validates_length_of :name, :maximum => 127
  default_scope :order => 'name ASC'
  
  def shifts
    skillissues = []
    self.users.each do |user|
      usrissues = Issue.all.select {|i| i.is_labcoach_shift? && (i.assigned_to_id == user.id) }
      usrissues.collect {|ui| skillissues << ui }
    end
    return skillissues
  end
  
  def timeslots
    slots = []
    self.users.each do |user|
      issues = Issue.all.select {|i| i.assigned_to[:id] == user[:id] }
        issues.each do |issue|
          issue.timeslots.each do |slot|
          slots << slot
          end
        end
    end
    return slots
  end
end
