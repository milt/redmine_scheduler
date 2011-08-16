class Hooks < Redmine::Hook::ViewListener
  
  def controller_issues_new_before_save(context={})
    s_time = DateTime.parse(context[:params][:issue][:start_time])
    e_time = DateTime.parse(context[:params][:issue][:end_time])
    s_date = Date.parse(context[:params][:issue][:start_date])
    context[:issue].write_attribute :start_time, Time.local(s_date.year,s_date.month,s_date.day,s_time.hour,s_time.min)
    context[:issue].write_attribute :end_time, Time.local(s_date.year,s_date.month,s_date.day,e_time.hour,e_time.min)
  end
  
  def controller_issues_new_after_save(context={})
    # If the issue is on the Lab Coach tracker, make shift_duration x timeslots numbering from 0
    if context[:issue].tracker.name == 'Lab Coach Shift'
      context[:issue].shift_duration_index.times {|i| context[:issue].timeslots << Timeslot.create(:slot_time => i)}
    end
  end

  def controller_issues_edit_before_save(context={})
    s_time = DateTime.parse(context[:params][:issue][:start_time])
    e_time = DateTime.parse(context[:params][:issue][:end_time])
    s_date = Date.parse(context[:params][:issue][:start_date])
    context[:issue].write_attribute :start_time, Time.local(s_date.year,s_date.month,s_date.day,s_time.hour,s_time.min)
    context[:issue].write_attribute :end_time, Time.local(s_date.year,s_date.month,s_date.day,e_time.hour,e_time.min)
  end

  def controller_issues_edit_after_save(context={})
    if context[:issue].tracker.name == 'Lab Coach Shift'
      context[:issue].timeslots.each do |slot|
        if slot.booking.nil? == false
          slot.booking.delete
        end
        slot.destroy
      end
      context[:issue].shift_duration_index.times {|i| context[:issue].timeslots << Timeslot.create(:slot_time => i)}
    end        
  end
end
