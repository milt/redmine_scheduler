class Hooks < Redmine::Hook::ViewListener
  def controller_issues_new_after_save(context={})
    # If the issue is on the Lab Coach tracker, make a timeslot
    if context[:issue].tracker.name == 'Lab Coach Shift'
      context[:issue].shift_duration_index.times {|i| context[:issue].timeslots << Timeslot.create(:slot_time => i) }
    else
    end
  end
  
  def controller_issues_edit_after_save(context={})
    # If the duration changes, delete timeslots as appropriate
    if context[:issue].tracker.name == 'Lab Coach Shift'
      unless context[:issue].timeslots.all.count == context[:issue].shift_duration_index
        until context[:issue].timeslots.all.count == context[:issue].shift_duration_index
          sort = context[:issue].timeslots.all.sort_by {|t| t[:slot_time]}
          if context[:issue].timeslots.all.count > context[:issue].shift_duration_index
            sort.last.destroy
          elsif context[:issue].timeslots.all.count < context[:issue].shift_duration_index
            context[:issue].timeslots << Timeslot.create(:slot_time => (sort.last[:slot_time] + 1))
          else
          end
        end
      end
    else
    end
  end
end