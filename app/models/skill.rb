class Skill < ActiveRecord::Base
  has_and_belongs_to_many :users, :uniq => true #HABM relationship uses the skills_users table, associations are unique so someone cannot have a skill more than once
  belongs_to :skillcat #each skill belongs to one category
  attr_accessible :name, :skillcat_id
  validates_uniqueness_of :name #skill names are unique
  validates_presence_of :name, :skillcat_id #every skill needs a name and a category
  validates_length_of :name, :maximum => 127 #skill names shouldn't be more than 127
  default_scope :order => 'name ASC' #default sort by name alphabetically ascending
  
  #todo: the following methods are bad and redundant, sort this craziness out
  def shifts(cutoff) #find shifts belonging to users with the given skill. called on a skill, looks for dates until cutoff
    skillissues = []
    self.users.each do |user| #for each user linked to the skill, find valid shifts
      usrissues = Issue.lcshift.foruser(user).until_date(cutoff) #old code below
      #usrissues = Issue.all.select {|i| (i.is_labcoach_shift? && (i.start_date <= cutoff)) && (i.assigned_to_id == user.id) }
      usrissues.collect {|ui| skillissues << ui }
    end
    return skillissues
  end
  
  def timeslots #find timeslots based on a skill. not sure where I used this, oh god...
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
