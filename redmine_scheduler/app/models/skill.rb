class Skill < ActiveRecord::Base
  has_and_belongs_to_many :users, :uniq => true
  belongs_to :skillcat
  validates_uniqueness_of :name
  
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
