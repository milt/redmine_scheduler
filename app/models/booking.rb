class Booking < ActiveRecord::Base
  has_many :timeslots, :dependent => :nullify
  has_many :issues, :through => :timeslots
  attr_accessible :name, :phone, :email, :project_desc
  validates_presence_of :name, :phone, :email, :project_desc #all form fields must exist be non-nil 
  validates_length_of :name, :email, :maximum => 127 #name can't be over 127 chars
  validates_length_of :phone, :maximum => 16 # phone max length of 16 chars
  validates_length_of :project_desc, :maximum => 1024 #limit the description field
  default_scope :order => 'apt_time ASC' #default sort order of Bookings
  named_scope :future, lambda { { :conditions => ["apt_time >= ?", Date.today] } }
  #named_scope :booked, lambda { { :conditions => "timeslot_id IS NOT NULL" } }
  named_scope :cancelled, lambda { { :conditions => { :cancelled => true } } }
  named_scope :orphaned, lambda { { :conditions => { :cancelled => nil, :timeslot_id => nil } } }
  validate_on_create :cannot_create_across_issues
  validate_on_create :cannot_create_on_multiple_days
  
  def apt_time=(time)
    write_attribute :apt_time, (time)
  end

  def cannot_create_across_issues
    @same_issue = true
    issue_id = @timeslots.first.issue_id

    @timeslots.each do |timeslot|
      if (timeslot.issue_id != issue_id)
        same_issue = false
        break
      end
    end

    errors.add_to_base("Cannot create booking because there timeslots across multiple issue categories") if
      @same_issue == false

  end

  def cannot_create_on_multiple_days
    @same_date = true
    date = @timeslots.first.slot_date

    @timeslots.each do |timeslot|
      if (timeslot.slot_date != date)
        same_date = false
        break
      end
    end
    
    errors.add_to_base("Cannot create booking because the timeslots span multiple days") if 
      @same_date == false
  end


  #not working, switched to controller.
  #validate :same_day(@timeslots)
  # def same_day(timeslots)
  #   same_date = true
  #   date = timeslots.first.slot_date

  #   timeslots.each do |timeslot|
  #     if (timeslot.slot_date != date)
  #       same_date = false
  #       break
  #     end
  #   end
  #   flash[:warning] = "timeslots need to on the same day" if same_date == false
  # end

  def coach
    self.timeslots.first.coach
  end

end
