class Repair < ActiveRecord::Base
  belongs_to :issue
  belongs_to :user
  after_validation_on_create :create_issue_after_validation

  def create_issue_after_validation
  	  i = Issue.new
      i.tracker = Tracker.repair_track.first
      i.project = Project.repair_project.first
      i.subject = "#{self.item_number} | #{self.item_desc} : #{self.problem_desc}"
      i.author = User.current
      i.start_date = Date.today
      if i.save
      	self.issue_id = i.id
      	return true
      else
      	return false
      end
  end
  
end