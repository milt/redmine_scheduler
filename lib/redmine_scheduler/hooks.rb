class Hooks < Redmine::Hook::ViewListener
  
  def controller_issues_new_before_save(context={})
    if context[:issue].is_shift?
      s_time = DateTime.parse(context[:params][:issue][:start_time])
      e_time = DateTime.parse(context[:params][:issue][:end_time])
      s_date = Date.parse(context[:params][:issue][:start_date])
      context[:issue].write_attribute :due_date, DateTime.parse(context[:params][:issue][:start_date]) if context[:issue].is_shift?
      context[:issue].write_attribute :start_time, Time.local(s_date.year,s_date.month,s_date.day,s_time.hour,s_time.min)
      context[:issue].write_attribute :end_time, Time.local(s_date.year,s_date.month,s_date.day,e_time.hour,e_time.min)
      context[:issue].write_attribute :subject, User.find(context[:params][:issue][:assigned_to_id]).firstname + s_time.strftime(' %l:%M -') + e_time.strftime('%l:%M %p - ') + s_date.strftime('%a, %b %d') rescue "No staff member selected. Please assign!"
    end      
  end
  
  def controller_issues_new_after_save(context={})
    if context[:params][:repeat_ends].present?
      r_ends = Date.strptime(context[:params][:repeat_ends], '%F')
    else
      r_ends = ""
    end
    if r_ends.present? && (r_ends > context[:issue].start_date)
      #Get delta between ticket creation and repeat end
      d_delt = ((r_ends - context[:issue].start_date).to_i)/7
      d_delt.times do |rep|
          i = Issue.new
          i.copy_from(context[:issue])
          i.start_date = context[:issue].start_date + (rep + 1).week
          i.due_date = context[:issue].due_date + (rep + 1).week
          i.start_time = context[:issue].start_time + (rep + 1).week
          i.end_time = context[:issue].end_time + (rep + 1).week
          i.subject = User.find(i.assigned_to_id).firstname + i.start_time.strftime(' %l:%M -') + i.end_time.strftime('%l:%M %p - ') + i.start_date.strftime('%a, %b %d')
          i.description = "Created by repeater"
          i.save
          if context[:issue].is_labcoach_shift?
            i.create_timeslots
          end
      end
    end
    # If the issue is on the Lab Coach tracker, make shift_duration x timeslots numbering from 0
    if context[:issue].is_labcoach_shift?
      context[:issue].create_timeslots
    end
  end

  def controller_issues_edit_before_save(context={})
    if context[:issue].is_shift?
      s_time = DateTime.parse(context[:params][:issue][:start_time])
      e_time = DateTime.parse(context[:params][:issue][:end_time])
      s_date = Date.parse(context[:params][:issue][:start_date])
      context[:issue].write_attribute :due_date, DateTime.parse(context[:params][:issue][:start_date]) if context[:issue].is_shift?
      context[:issue].write_attribute :start_time, Time.local(s_date.year,s_date.month,s_date.day,s_time.hour,s_time.min)
      context[:issue].write_attribute :end_time, Time.local(s_date.year,s_date.month,s_date.day,e_time.hour,e_time.min)
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
      context[:issue].create_timeslots
    end        
  end
  
    render_on :view_issues_form_details_bottom,
              :partial => 'hooks/redmine_scheduler/hello'
end
