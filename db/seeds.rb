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

#remove builtin, add custom trackers to projects
front_desk_project.trackers.delete_all
front_desk_project.trackers << fd_tracker

lab_coach_project.trackers.delete_all
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

