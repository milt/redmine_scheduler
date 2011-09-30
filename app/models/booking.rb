class Booking < ActiveRecord::Base
  belongs_to :timeslot
  validates_presence_of :name, :phone, :email, :project_desc
  validates_length_of :name, :email, :maximum => 127
  validates_length_of :phone, :maximum => 16
  validates_length_of :project_desc, :maximum => 1024
  default_scope :order => 'apt_time ASC'
  
end
