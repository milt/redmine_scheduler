#let's add some shifts. This assumes that seeds has run, and has set up projects, trackers, users, groups etc.
#doesn't work, not sure why yet

stustaff = Group.find(:all, :conditions => ["lastname = ?","Stustaff"]).first.users
fd_project = Project.find(:all,:conditions => ["name = ?","Front Desk Scheduling"]).first
lc_project = Project.find(:all,:conditions => ["name = ?","Lab Coach Scheduling"]).first
fd_tracker = Tracker.fdshift_track.first
lc_tracker = Tracker.lcshift_track.first
manager = User.find(:all, :conditions => ["lastname = ?", "Manager"]).first

from_date_time = DateTime.now - 3.weeks
from_date = Date.today - 3.weeks

for p in 0..21 do
  date = Date.today - p.days
  start = date.to_datetime + 9.hours
  finish = start + 8.hours

  stustaff.each do |staffer|
      #make a shift
      i = Issue.new
      i.tracker = fd_tracker
      i.project = fd_project
      i.assigned_to = staffer
      i.subject = "#{staffer.firstname} #{date.to_s} : #{start.to_s} to #{finish.to_s}"
      i.author = manager
      i.start_date = date
      i.start_time = start
      i.end_time = finish
      i.save

      #make a time entry
      te = TimeEntry.create(:project => fd_project, :user => staffer, :issue => i, :hours => 8.0, :comments => "I did a thing", :activity => TimeEntryActivity.find(10), :spent_on => date)

  end
end

for p in 0..60 do
  date = Date.today + p.days
  start = date.to_datetime + 12.hours
  finish = start + 4.hours

  stustaff.each do |staffer|
      #make a shift
      i = Issue.new
      i.tracker = lc_tracker
      i.project = lc_project
      i.assigned_to = staffer
      i.subject = "#{staffer.firstname} #{date.strftime("%D")} : #{start.strftime("%T")} to #{finish.strftime("%T")}"
      i.author = manager
      i.start_date = date
      i.start_time = start
      i.end_time = finish
      i.save
  end
end
