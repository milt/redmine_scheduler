class Printing3d < ActiveRecord::Base
  unloadable

  acts_as_attachable  # includes everything from redmine module 'attachable'
  
  monetize :total_cents
  monetize :deposit_cents
  belongs_to :user
  belongs_to :issue

  validates :user,
            :issue,
            :dropoff,
            :pickup,
            :patron_name,
            :patron_phone,
            :patron_dept,
            :patron_email,
            :affiliation,
            :print_weight,
            :material_type,
            :payment_type,
            :total_cents,
            :deposit_cents,
            :quantity, presence: true

  validates :patron_email, email: true

  # commented out for testing purposes
  # validates :file_name, presence: { message: "You must choose a file for upload!"}
  validates :total_cents, :deposit_cents, numericality: { only_integer: true }  # no floats allowed

  validate :deposit_is_sufficient  # at least a deposit of half the cost
  validate :pickup_must_be_at_least_48_hours_from_dropoff

  validates :affiliation, :inclusion => { :in => %w(student staff dmc),
    :message => "%{value} is not a valid affiliation" }
  validates :payment_type, :inclusion => { :in => %w(jcash check budget),
    :message => "%{value} is not a valid paper type" }

  validates :issue_id, uniqueness: true
  validates_associated :issue  # only one end needed, avoid infinite loop

  validates :payment_reference, :presence => true, :if => Proc.new { |p| p.payment_type == "check" }
  validates :budget_number,
            :budget_name,
            :budget_email,
            :budget_phone,
            :presence => true, :if => Proc.new { |p| p.payment_type == "budget" }

  validates :budget_email, :email => true, :if => Proc.new { |p| p.payment_type == "budget" }

  before_validation :build_issue_for_printing3d, :unless => :issue_id?

  #commented out for testing purpose
  # after_save :move_attachments_to_issue

  validate :weight_limit
  validates :print_weight, numericality: { greater_than: 5.0}  # auto output error
  validates :material_type, :inclusion => { :in => %w(ABS HDPE PLA PVA),
    :message => "%{value} is not a valid material type" }

  def pickup_must_be_at_least_48_hours_from_dropoff
    if (pickup - dropoff)/60/60 < 48.0
      errors.add(:pickup, "can't be less than 48 hours from dropoff.")
    end
  end

  def weight_limit
    unless (print_weight == nil)
      if (print_weight) > 44.0
        errors.add(:print_weight, "printed material can't exceed 44g in weight!")
      end
    end
  end

  def deposit_is_sufficient
    unless (affiliation == "dmc") || (payment_type == "budget") || total == 0
      if (deposit < (total/2))
        errors.add(:deposit, "Can't be less than 1/2 of total.")
      end
    end
  end


  def build_issue_for_printing3d
    i = self.build_issue
    i.tracker = Tracker.printing3d_track.first
    i.project = Project.printing3d_project.first
    i.subject = "#{patron_name} | #{file_name} | #{material_type}\" | #{print_weight}\""
    i.author = User.current
    i.start_date = Date.today
  end

  def move_attachments_to_issue
    attachments.each do |attachment|
      issue.attachments << attachment
    end
  end

  def minimum_deposit
  end

  def balance_due
    total - deposit
  end

end
