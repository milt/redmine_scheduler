#load some defaults for the DMC plugin

#Required Projects
front_desk_project_params = {
  :name => "Front Desk Scheduling",
  :description => "Project for Front Desk scheduling",
  :homepage => "",
  :is_public => false,
  :identifier => "front-desk",
  :status => 1
}

front_desk_project = Project.create(front_desk_project_params)

lab_coach_project_params = {
  :name => "Lab Coach Scheduling",
  :description => "Project for Lab Coach scheduling",
  :homepage => "",
  :is_public => false,
  :identifier => "labcoachtime",
  :status => 1
}

lab_coach_project = Project.create(lab_coach_project_params)

#Required Trackers
fd_tracker_params = {
  :name => "Front Desk Shift",
  :is_in_chlog => false,
  :is_in_roadmap => false
}

fd_tracker = Tracker.create(fd_tracker_params)

lc_tracker_params = {
  :name => "Lab Coach Shift",
  :is_in_chlog => false,
  :is_in_roadmap => false
}

lc_tracker = Tracker.create(lc_tracker_params)

#add staff role
staff_role_params = {
  :name => "Staff",
  :assignable => true,
  :builtin => 0,
  :permissions => [
  	:view_skills,
  	:add_messages,
  	:edit_own_messages,
  	:delete_own_messages,
  	:view_calendar,
  	:view_documents,
  	:view_files,
  	:view_gantt,
  	:view_issues,
  	:edit_issues,
  	:add_issue_notes,
  	:edit_own_issue_notes,
  	:save_queries,
  	:comment_news,
  	:browse_repository,
  	:view_changesets,
  	:log_time,
  	:view_time_entries,
  	:view_wiki_pages,
  	:view_wiki_edits,
  	:edit_wiki_pages,
  	:protect_wiki_pages
  ]
}

staff_role = Role.create(staff_role_params)

#make default modules
shift_module_params = [
  "calendar",
  "documents",
  "news",
  "time_tracking",
  "issue_tracking"
]
#add them to default groups
#shift_module_params.each do |module|
#  front_desk_project.enabled_modules << EnabledModule.new(:name => module)
#  lab_coach_project.enabled_modules << EnabledModule.new(:name => module)
#end


front_desk_project.trackers.clear
front_desk_project.trackers << fd_tracker

lab_coach_project.trackers.clear
lab_coach_project.trackers << lc_tracker

#Default skillcat
skillcat_params = {
  :name => "General",
  :descr => "Lab coach has general knowledge of a given discipline."
}

skillcat = Skillcat.create(skillcat_params)

new_skills = [
  "2D Design",
  "3D Modeling",
  "Animation",
  "Audio",
  "Gaming",
  "Interactive Design (web)",
  "Maker / Hacker",
  "Photography",
  "Programming",
  "Video"
]

#add with category
new_skills.each do |skillname|
  Skill.create({:name => skillname, :skillcat_id => skillcat})
end

#load authentication method for PAM.
auth_params = {
  :name => "PAM",
  :host => "localhost",
  :port => 1,
  :account => "user",
  :account_password => "pass",
  :base_dn => "app",
  :attr_login => "name",
  :attr_firstname => "firstname",
  :attr_lastname => "lastname",
  :attr_mail => "email",
  :onthefly_register => false,
  :tls => false
}

pam_auth_source = AuthSource.new(auth_params)
pam_auth_source.type = "AuthSourcePam" #Only seems to work with type declared separately and as a string, probably an STI thang?
pam_auth_source.save

#Dummy Users

#student staff manager
manager = User.create(:firstname => "Deborah", :lastname => "Manager", :mail => "mgr@fake.edu")
manager.login = "manager"
manager.password = "password"
manager.admin = true
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

#add skills for these users

#add groups: prostaff, stustaff
prostaffgroup = Group.create!(:lastname => "Prostaff", :type => "Group")
stustaffgroup = Group.create!(:lastname => "Stustaff", :type => "Group")

#add users to groups

#add manager to the projects using the manager role.

# add student staff to the projects using the staff role






