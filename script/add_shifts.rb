#-------------previously located in seeds.rb----------------
#student staff manager
manager = User.create(:firstname => "Deborah", :lastname => "Manager", :mail => "mgr@fake.edu")
manager.login = "manager"
manager.password = "password"
manager.admin = false
manager.save

#prostaff
prostaff1 = User.create(:firstname => "Joe", :lastname => "Prostaff", :mail => "ps1@fake.edu")
prostaff1.login = "prostaff1"
prostaff1.password = "password"
prostaff1.save

prostaff2 = User.create(:firstname => "Rose", :lastname => "Prostaff", :mail => "ps2@fake.edu")
prostaff2.login = "prostaff2"
prostaff2.password = "password"
prostaff2.save


#Stustaff
stustaff1 = User.create(:firstname => "Morgan", :lastname => "Stustaff", :mail => "ss1@fake.edu")
stustaff1.login = "stustaff1"
stustaff1.password = "password"
stustaff1.save

stustaff2 = User.create(:firstname => "Jay", :lastname => "Stustaff", :mail => "ss2@fake.edu")
stustaff2.login = "stustaff2"
stustaff2.password = "password"
stustaff2.save

stustaff3 = User.create(:firstname => "Carlos", :lastname => "Stustaff", :mail => "ss3@fake.edu")
stustaff3.login = "stustaff3"
stustaff3.password = "password"
stustaff3.save

stustaff4 = User.create(:firstname => "FakeStudent", :lastname => "Stustaff", :mail => "dontfakemeout@fake.edu")
stustaff4.login = "stustaff4"
stustaff4.password = "password"
stustaff4.save

#add users to groups
User.find(:all, :conditions => ["lastname = ?", "Prostaff"]).map {|u| prostaffgroup.users << u}
User.find(:all, :conditions => ["lastname = ?", "Stustaff"]).map {|u| stustaffgroup.users << u}
User.find(:all, :conditions => ["lastname = ?", "Manager"]).map {|u| managergroup.users << u}

#give wages to all stustaff
stustaffgroup.users.each do |u|
  u.create_wage(:amount => 12.0)
end

# assign 3 random skill levels to stustaff
stustaff = stustaffgroup.users

stustaff.each do |staffer|
  3.times do
    level = Level.create(:user => staffer, :skill => Skill.find(rand(Skill.count)+1), :rating => rand(4))
  end
end
#-------------------------------code above previously from seeds.rb------------------------------------

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
  start = date + 9.hours + 15.minutes
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

for p in 0..20 do
  date = Date.today + p.days
  start = date + 12.hours + 15.minutes
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
