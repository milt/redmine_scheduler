class Repair < ActiveRecord::Base
  belongs_to :issue
  belongs_to :user
  validates :item_number, :item_desc, :problem_desc, presence: true
  validates :item_number, numericality: true
  validates :item_desc, length: {maximum: 128}
  validates :problem_desc, length: {maximum: 1024}
  validates :notes, length: {maximum: 2048}
  after_validation :create_issue_after_validation, on: :create
  scope :for_issue, lambda {|i| { :conditions => ["issue_id = ?", i.id] } }

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