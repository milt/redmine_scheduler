class Repair < ActiveRecord::Base
  belongs_to :issue
  belongs_to :user
  validates_presence_of :item_number, :item_desc, :problem_desc
  validates_numericality_of :item_number
  validates_length_of :item_desc, :maximum => 128
  validates_length_of :problem_desc, :maximum => 1024
  validates_length_of :notes, :maximum => 2048
  after_validation_on_create :create_issue_after_validation
  named_scope :for_issue, lambda {|i| { :conditions => ["issue_id = ?", i.id] } }

  def create_issue_after_validation
  	  i = Issue.new
      i.tracker = Tracker.repair_track.first
      i.project = Project.repair_project.first
      i.subject = "#{self.item_number} | #{self.item_desc} : #{self.problem_desc[0..200]}"
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