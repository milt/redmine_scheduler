#Find groups created by seeds file

prostaffgroup = Group.find(:all, :conditions => ["lastname = ?", "Prostaff"]).first
stustaffgroup = Group.find(:all, :conditions => ["lastname = ?", "Stustaff"]).first
managergroup = Group.find(:all, :conditions => ["lastname = ?", "Manager"]).first

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
  u.create_wage(:amount => 12)
end

# assign 3 random skill levels to stustaff
stustaff = stustaffgroup.users

stustaff.each do |staffer|
  3.times do
    level = Level.create(:user => staffer, :skill => Skill.find(rand(Skill.count)+1), :rating => rand(4))
  end
end
