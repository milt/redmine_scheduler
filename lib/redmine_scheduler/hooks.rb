class Hooks < Redmine::Hook::ViewListener #this is where we hook into redmine controllers and views. I'm not going to sugarcoat it, this is a damned mess, so much of this shouldn't be happening here
  
  def controller_issues_new_before_save(context={}) #runs before a new issue saves
    if context[:issue].is_shift? # if the issue is a shift,
      #get times and date from form params
      s_time = DateTime.parse(context[:params][:issue][:start_time])
      e_time = DateTime.parse(context[:params][:issue][:end_time])
      s_date = Date.parse(context[:params][:issue][:start_date])
      context[:issue].write_attribute :due_date, DateTime.parse(context[:params][:issue][:start_date]) if context[:issue].is_shift? # limits shifts to only have a due_date on the same day as the start, or none
      context[:issue].write_attribute :start_time, Time.local(s_date.year,s_date.month,s_date.day,s_time.hour,s_time.min) #format and set start_time
      context[:issue].write_attribute :end_time, Time.local(s_date.year,s_date.month,s_date.day,e_time.hour,e_time.min) #format and set end_time
      context[:issue].write_attribute :subject, User.find(context[:params][:issue][:assigned_to_id]).firstname + s_time.strftime(' %l:%M -') + e_time.strftime('%l:%M %p - ') + s_date.strftime('%a, %b %d') rescue "No staff member selected. Please assign!" #set the subject field of shifts on update to indicate the staff member and datetime. rescue prevents shift issues without a staff member 
    end      
  end
  
  def controller_issues_new_after_save(context={}) #runs after a new issue saves
    if context[:params][:repeat_ends].present? #handles weekly repeating shift creation, in a scary way
      r_ends = Date.strptime(context[:params][:repeat_ends], '%F')
    else
      r_ends = ""
    end
    if r_ends.present? && (r_ends > context[:issue].start_date)
      #Get delta between ticket creation and repeat end
      d_delt = ((r_ends - context[:issue].start_date).to_i)/7 # in weeks
      d_delt.times do |rep| #for each week build a new shift, copying values from the created shift
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
            i.create_timeslots # create what is probably a shitload of timeslots
          end
      end
    end
    # If the issue is on the Lab Coach tracker, make shift_duration x timeslots numbering from 0
    if context[:issue].is_labcoach_shift?
      context[:issue].create_timeslots # create timeslots for the first shift.
    end
  end

  def controller_issues_edit_before_save(context={}) #runs before save on issue edit
    if context[:issue].is_shift?
      #get times and date from form params
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

  def controller_issues_edit_after_save(context={}) #runs after save on issue edit
    if context[:issue].is_labcoach_shift?
      context[:issue].recreate_timeslots # see the Issue patch
    end        
  end
  
    render_on :view_issues_form_details_bottom, #this is how you attach stuff to views. you can also overwrite them by putting them in the /app/ tree of the plugin
              :partial => 'hooks/redmine_scheduler/hello'

    render_on :view_timelog_edit_form_bottom, #this is how you attach stuff to views. you can also overwrite them by putting them in the /app/ tree of the plugin
              :partial => 'hooks/redmine_scheduler/timex'
end
