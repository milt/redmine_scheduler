class Repair < ActiveRecord::Base
  belongs_to :issue
  belongs_to :user
  has_one :fine
  validates :item_number, :item_desc, :problem_desc, presence: true
  validates :item_number, numericality: true
  validates :item_desc, length: {maximum: 128}
  validates :problem_desc, length: {maximum: 1024}
  validates :notes, length: {maximum: 2048}
  validates :issue_id, uniqueness: true
  validates_associated :issue
  before_validation :build_issue_for_repair, :unless => :issue_id?
  scope :for_issue, lambda {|i| { :conditions => ["issue_id = ?", i.id] } }

  def build_issue_for_repair
    i = self.build_issue
    i.tracker = Tracker.repair_track.first
    i.project = Project.repair_project.first
    i.subject = "#{self.item_number} | #{self.item_desc} : #{self.problem_desc[0..200]}"
    i.author = User.current
    i.start_date = Date.today
  end
end