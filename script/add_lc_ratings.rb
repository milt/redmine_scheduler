stustaff = Group.find(:all, :conditions => ["lastname = ?","Stustaff"]).first.users
manager = User.find(:all, :conditions => ["lastname = ?", "Manager"]).first
rater = User.where(lastname:'Anonymous').first

# check models/lc_rating.rb for details/validation procedures
for p in 0..21 do
  date = Date.today - p.days

  lcshifts = Issue.shifts.from_date(date).until_date(date)

  lcshifts.each do |lcshift|
      #make a lc_rating
      i = LcRating.new
      i.rater_user_id = rater.id
      i.rated_user_id = lcshift.assigned_to_id
      i.issue_id = lcshift.id
      i.rating = rand(11)  #0 to 10
      i.comment = 'this is a lab coach rating ..'
      i.save
  end
end
