class Hooks < Redmine::Hook::ViewListener
  
  def controller_issues_new_before_save(context={})
    s_time = DateTime.parse(context[:params][:issue][:start_time])
    e_time = DateTime.parse(context[:params][:issue][:end_time])
    s_date = Date.parse(context[:params][:issue][:start_date])
    context[:issue].write_attribute :start_time, Time.local(s_date.year,s_date.month,s_date.day,s_time.hour,s_time.min)
    context[:issue].write_attribute :end_time, Time.local(s_date.year,s_date.month,s_date.day,e_time.hour,e_time.min)
    if context[:issue].is_shift?
      context[:issue].write_attribute :subject, User.find(context[:params][:issue][:assigned_to_id]).firstname + s_time.strftime(' %l:%M -') + e_time.strftime('%l:%M %p - ') + s_date.strftime('%a, %b %d') rescue "No staff member selected. Please assign!"
    end
  end
  
  def controller_issues_new_after_save(context={})
    # If the issue is on the Lab Coach tracker, make shift_duration x timeslots numbering from 0
    if context[:issue].is_labcoach_shift?
      context[:issue].shift_duration_index.times {|i| context[:issue].timeslots << Timeslot.create(:slot_time => i)}
    end
  end

  def controller_issues_edit_before_save(context={})
    s_time = DateTime.parse(context[:params][:issue][:start_time])
    e_time = DateTime.parse(context[:params][:issue][:end_time])
    s_date = Date.parse(context[:params][:issue][:start_date])
    context[:issue].write_attribute :start_time, Time.local(s_date.year,s_date.month,s_date.day,s_time.hour,s_time.min)
    context[:issue].write_attribute :end_time, Time.local(s_date.year,s_date.month,s_date.day,e_time.hour,e_time.min)
    if context[:issue].is_shift?
      if context[:params][:issue][:assigned_to].present?
        context[:issue].write_attribute :subject, context[:params][:issue][:assigned_to] + s_time.strftime(' %l:%M -') + e_time.strftime('%l:%M %p - ') + s_date.strftime('%a, %b %d')
      else
        context[:issue].write_attribute :subject, context[:issue].assigned_to.firstname + s_time.strftime(' %l:%M -') + e_time.strftime('%l:%M %p - ') + s_date.strftime('%a, %b %d')
      end
    end
  end

  def controller_issues_edit_after_save(context={})
    if context[:issue].is_labcoach_shift?
      context[:issue].timeslots.each do |slot|
        if slot.booking.present?
          slot.booking.cancel
        end
        slot.destroy
      end
      context[:issue].shift_duration_index.times {|i| context[:issue].timeslots << Timeslot.create(:slot_time => i)}
    end        
  end
end
