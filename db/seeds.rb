#load some defaults for the DMC plugin

#Required Projects
front_desk_project_params = {
  :name => "Front Desk Scheduling",
  :description => "Project for Front Desk scheduling",
  :homepage => "",
  :is_public => false,
  :identifier => "front-desk",
  :status => 1,
  :suppress_email => true
}

front_desk_project = Project.create(front_desk_project_params)

lab_coach_project_params = {
  :name => "Lab Coach Scheduling",
  :description => "Project for Lab Coach scheduling",
  :homepage => "",
  :is_public => false,
  :identifier => "labcoachtime",
  :status => 1,
  :suppress_email => true
}

lab_coach_project = Project.create(lab_coach_project_params)

training_project_params = {
  :name => "Training Project",
  :description => "Project for Skill Training",
  :homepage => "",
  :is_public => false,
  :identifier => "training",
  :status => 1
}

training_project = Project.create(training_project_params)

development_project_params = {
  :name => "Development",
  :description => "Project for Development",
  :homepage => "",
  :is_public => false,
  :identifier => "development",  #what does this identifier field do?
  :status => 1
}

development_project = Project.create(development_project_params)

repair_project_params = {
  :name => "Repair & Replace",
  :description => "Project for Repair and Replacement of Equipment",
  :homepage => "",
  :is_public => false,
  :identifier => "repair-replace",
  :status => 1
}

repair_project = Project.create(repair_project_params)

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

development_tracker_params = {
  :name => "Development",
  :is_in_chlog => false,
  :is_in_roadmap => false
}

development_tracker = Tracker.create(development_tracker_params)

task_tracker_params = {
  :name => "Task",
  :is_in_chlog => false,
  :is_in_roadmap => false
}

task_tracker = Tracker.create(task_tracker_params)

goal_tracker_params = {
  :name => "Training Goal",
  :is_in_chlog => false,
  :is_in_roadmap => false
}

goal_tracker = Tracker.create(goal_tracker_params)

event_tracker_params = {
  :name => "Event",
  :is_in_chlog => false,
  :is_in_roadmap => false
}

event_tracker = Tracker.create(event_tracker_params)

equipment_problem_tracker_params = {
  :name => "Equipment Problem",
  :is_in_chlog => false,
  :is_in_roadmap => false
}

equipment_problem_tracker = Tracker.create(equipment_problem_tracker_params)

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
    :edit_own_time_entries,
  	:view_wiki_pages,
  	:view_wiki_edits,
  	:edit_wiki_pages,
  	:protect_wiki_pages
  ]
}

staff_role = Role.create(staff_role_params)

#add workflows
Workflow.copy_one(Tracker.find(3), Role.find(3), fd_tracker, Role.find(3))
Workflow.copy_one(Tracker.find(3), Role.find(4), fd_tracker, staff_role)

Workflow.copy_one(Tracker.find(3), Role.find(3), lc_tracker, Role.find(3))
Workflow.copy_one(Tracker.find(3), Role.find(4), lc_tracker, staff_role)

Workflow.copy_one(Tracker.find(3), Role.find(3), task_tracker, Role.find(3))
Workflow.copy_one(Tracker.find(3), Role.find(4), task_tracker, staff_role)

Workflow.copy_one(Tracker.find(3), Role.find(3), goal_tracker, Role.find(3))
Workflow.copy_one(Tracker.find(3), Role.find(4), goal_tracker, staff_role)

Workflow.copy_one(Tracker.find(3), Role.find(3), equipment_problem_tracker, Role.find(3))
Workflow.copy_one(Tracker.find(3), Role.find(4), equipment_problem_tracker, staff_role)

activity_list = [
  "Helping Patrons",
  "Self Training",
  "Cleaning",
  "Training",
  "Helping Staff",
  "Troubleshooting",
  "Documentation",
  "Design",
  "Development",
  "Working Event",
  "Equipment Repair",
  "Promotion"
]

activities = activity_list.map {|a| TimeEntryActivity.create(:name => a)}
front_desk_project.activities << activities
lab_coach_project.activities << activities
training_project.activities << activities
development_project.activities << activities
repair_project.activities << activities

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

training_project.trackers.clear
training_project.trackers << goal_tracker

development_project.trackers.clear
development_project.trackers << development_tracker
development_project.trackers << Tracker.find(:first,:conditions=>["name ='Bug'"])  #add the bug tracker
development_project.trackers << Tracker.find(:first,:conditions=>["name = 'Feature'"])  #add the feature tracker

repair_project.trackers.clear
repair_project.trackers << equipment_problem_tracker

#Default skillcat
skillcat_general_params = {
  :name => "General",
  :descr => "Lab coach has general knowledge of a given discipline."
}

#authorization category added
skillcat_authorization_params = {
  :name => "Authorization",
  :descr => "Authorization for the use of equipments??"
}
skillcat = Skillcat.create(skillcat_general_params)
skillcat_auth = Skillcat.create(skillcat_authorization_params)

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

#changing the name does not fix the error of assigning to the wrong category...
new_skills2 = [
  "testskill1",
  "testskill2",
  "testskill3",
  "testskill4"
]
#add test values to authorization cat, somehow this adds the skills to general category instead..
new_skills2.each do |skillname2|
  Skill.create({:name => skillname2, :skillcat_id => skillcat_auth})
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

#add groups: prostaff, stustaff
prostaffgroup = Group.create!(:lastname => "Prostaff", :type => "Group")
stustaffgroup = Group.create!(:lastname => "Stustaff", :type => "Group")
managergroup = Group.create!(:lastname => "Manager", :type => "Group")

#add groups to project roles
fd_managermember = Member.new(:principal => managergroup, :project => front_desk_project)
fd_managermember.member_roles << MemberRole.new(:role => Role.find(3))
fd_managermember.save

fd_staffmember = Member.new(:principal => stustaffgroup, :project => front_desk_project)
fd_staffmember.member_roles << MemberRole.new(:role => staff_role)
fd_staffmember.save

lc_managermember = Member.new(:principal => managergroup, :project => lab_coach_project)
lc_managermember.member_roles << MemberRole.new(:role => Role.find(3))
lc_managermember.save

lc_staffmember = Member.new(:principal => stustaffgroup, :project => lab_coach_project)
lc_staffmember.member_roles << MemberRole.new(:role => staff_role)
lc_staffmember.save

training_managermember = Member.new(:principal => prostaffgroup, :project => training_project)
training_managermember.member_roles << MemberRole.new(:role => Role.find(3))
training_managermember.save

training_staffmember = Member.new(:principal => stustaffgroup, :project => training_project)
training_staffmember.member_roles << MemberRole.new(:role => staff_role)
training_staffmember.save

development_managermember = Member.new(:principal => managergroup, :project => development_project)
development_managermember.member_roles << MemberRole.new(:role => Role.find(3))
development_managermember.save

development_staffmember = Member.new(:principal => stustaffgroup, :project => development_project)
development_staffmember.member_roles << MemberRole.new(:role => staff_role)
development_staffmember.save

repair_managermember = Member.new(:principal => managergroup, :project => repair_project)
repair_managermember.member_roles << MemberRole.new(:role => Role.find(3))
repair_managermember.save

repair_staffmember = Member.new(:principal => prostaffgroup, :project => repair_project)
repair_staffmember.member_roles << MemberRole.new(:role => staff_role)
repair_staffmember.save
