class Hooks < Redmine::Hook::ViewListener
  def :controller_issues_new_after_save(context={ })
    # Create a new timeslot for every issue
    context[:issue].timeslots << Timeslot.create
  end
end