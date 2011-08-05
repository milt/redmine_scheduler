class Hooks < Redmine::Hook::ViewListener
  def controller_issues_new_after_save(context={})
    # If the issue is on the Lab Coach tracker, make a timeslot
    if context[:issue].tracker == 'Lab Coach Shift'
      context[:issue].timeslots << Timeslot.create
    else
    end
  end
end