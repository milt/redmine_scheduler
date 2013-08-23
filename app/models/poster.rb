class Poster < ActiveRecord::Base
  unloadable
  acts_as_attachable
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
            :print_width,
            :print_height,
            :border,
            :paper_type,
            :payment_type,
            :total_cents,
            :deposit_cents,
            :quantity, presence: true

  validates :file_name, presence: { message: "You must choose a file for upload!"}
  validates :total_cents, :deposit_cents, numericality: { only_integer: true }

  validate :width_and_border_limit
  validate :deposit_is_sufficient

  validates :print_width, :print_height, numericality: { greater_than: 17.0}

  validates :affiliation, :inclusion => { :in => %w(student staff dmc),
    :message => "%{value} is not a valid affiliation" }
  validates :paper_type, :inclusion => { :in => %w(matte glossy),
    :message => "%{value} is not a valid paper type" }
  validates :payment_type, :inclusion => { :in => %w(jcash check budget),
    :message => "%{value} is not a valid paper type" }

  validates :issue_id, uniqueness: true
  validates_associated :issue
  before_validation :build_issue_for_poster, :unless => :issue_id?
  after_save :move_attachments_to_issue


      
      # :payment_reference
      # :budget_number
      # :budget_name
      # :budget_email
      # :budget_phone
      # :total_cents
      # :deposit_cents
      # :notes

  def width_and_border_limit
    unless (print_width == nil) || (print_height == nil)
      if (print_width + border) > 44.0
        errors.add(:print_width, "can't exceed 44 inches.")
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


  def build_issue_for_poster
    i = self.build_issue
    i.tracker = Tracker.poster_track.first
    i.project = Project.poster_project.first
    i.subject = "#{patron_name} | #{file_name} | #{print_width}\" x #{print_height}\""
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

  def aspect_ratio
    print_width / print_height
  end

end
