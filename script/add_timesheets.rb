
# TODO link this with add_shifts and add_bookings at runtime
# TODO need to add time_entries...how did timesheets get created without any time_entries??


stustaff = Group.find(:all, :conditions => ["lastname = ?","Stustaff"]).first.users
manager = User.find(:all, :conditions => ["lastname = ?", "Manager"]).first

for p in 0..3 do
  day_within_week = Date.today - p.week
  week_start = day_within_week.monday  #retrieves monday of the week

  stustaff.each do |staffer|
      #make a timesheet
      i = Timesheet.new
      i.user_id = staffer.id
      i.weekof = week_start
      i.notes = "this is gibberish..."
  	  i.created_at = DateTime.now
      # i.approve_time_wage_cents = staffer.amount_cents  #apparently this can be left nil, each staff pre-assigned a wage already
      i.save
  end
end


