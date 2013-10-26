# Repairs auto-creation for testing purposes

stustaff = Group.find(:all, :conditions => ["lastname = ?","Stustaff"]).first.users
# repair_project = Project.where (name:"Repair & Replace").first
repair_project = Project.repair_project.first
repair_tracker = Tracker.repair_track.first
manager = User.find(:all, :conditions => ["lastname = ?", "Manager"]).first

for p in 0..2 do

  stustaff.each do |staffer|
      # make a repair/replacement request, specifically new equipment order in this case
	  # issue tracker, project, subject, author, and start_date taken care of by build_issue_for_repair
      r = Repair.new
      r.item_number = rand.to_s[2..5]
      r.item_desc = "New Equipment Purchase Request .. "
      r.problem_desc = "this is a equipment repair problem description .. "
      r.save

      # after repair issue auto-creation
      i = r.issue
      i.assigned_to = manager
      i.save
  end
end

