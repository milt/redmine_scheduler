class Booking < ActiveRecord::Base
  belongs_to :timeslot
<<<<<<< HEAD
  validates_presence_of :name, :phone, :email
=======
  validates_presence_of :name, :phone, :email, :project_desc
>>>>>>> improvements fixes for issue hooks
  validates_length_of :name, :email, :maximum => 127
  validates_length_of :phone, :maximum => 16
  validates_length_of :project_desc, :maximum => 1024
  
end
