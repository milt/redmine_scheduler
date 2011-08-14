class Hooks < Redmine::Hook::ViewListener
  def controller_issues_new_after_save(context={})
    # If the issue is on the Lab Coach tracker, make a timeslot
    if context[:issue].tracker.name == 'Lab Coach Shift'
      context[:issue].shift_duration_index.times {|i| context[:issue].timeslots << Timeslot.create(:slot_time => i) }
    else
    end
  end
  
  def controller_issues_edit_after_save(context={})

  end
end