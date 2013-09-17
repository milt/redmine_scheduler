
# TODO link this to add_shifts.rb at runtime
# use crontab for periodic updates?

stustaff = Group.find(:all, :conditions => ["lastname = ?","Stustaff"]).first.users

# from_date_time = DateTime.now - 3.weeks
# from_date = Date.today - 3.weeks

# check models/booking.rb for details/validation procedures
# creating past bookings
for p in 0..21 do
  date = Date.today - p.days
  start = date + 9.hours + 15.minutes
  finish = start + 8.hours

  stustaff.each do |staffer|
      #make a booking
      i = Booking.new
      i.name = staffer.firstname + ' ' + staffer.lastname
      i.phone = rand.to_s[2..11]
   	  i.email = staffer.mail
   	  i.project_desc = "#{staffer.firstname} is here!"
   	  i.apt_time = start
   	  i.created_at = DateTime.now
   	  i.coach_id = i.id
   	  i.author_id = i.id
   	  i.timeslots << Timeslot.find(rand(Timeslot.all.size)+1)
      i.save
  end
end

# for p in 0..20 do
#   date = Date.today + p.days
#   start = date + 12.hours + 15.minutes
#   finish = start + 4.hours

#   stustaff.each do |staffer|
#       #make a shift
#       i = Issue.new
#       i.tracker = lc_tracker
#       i.project = lc_project
#       i.assigned_to = staffer
#       i.subject = "#{staffer.firstname} #{date.strftime("%D")} : #{start.strftime("%T")} to #{finish.strftime("%T")}"
#       i.author = manager
#       i.start_date = date
#       i.start_time = start
#       i.end_time = finish
#       i.save
#   end
# end

