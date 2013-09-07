class Hooks < Redmine::Hook::ViewListener #this is where we hook into redmine controllers and views. I'm not going to sugarcoat it, this is a damned mess, so much of this shouldn't be happening here
  
  def controller_issues_new_before_save(context={}) #runs before a new issue saves
    if context[:issue].is_shift? # if the issue is a shift,
      @issue = context[:issue] 
      s_date = Date.parse(context[:params][:issue][:start_date])
      s_time = context[:params][:issue][:start_time].to_i
      e_time = context[:params][:issue][:end_time].to_i
      
      @issue.set_times_from_index(s_date, 15.minutes, s_time, e_time)
      @issue.due_date = @issue.start_date
      @issue.refresh_shift_subject
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
          i.refresh_shift_subject
          i.description = "Created by repeater"
          i.save
      end
    end
  end

  def controller_issues_edit_before_save(context={}) #runs before save on issue edit
    if context[:issue].is_shift?
      #get times and date from form params
      @issue = context[:issue] 
      s_date = Date.parse(context[:params][:issue][:start_date])
      s_time = context[:params][:issue][:start_time].to_i
      e_time = context[:params][:issue][:end_time].to_i
 
      @issue.set_times_from_index(s_date, 15.minutes, s_time, e_time)

      if @issue.start_time_changed? || @issue.end_time_changed? || @issue.start_date_changed? || @issue.due_date_changed?
        @issue.due_date = @issue.start_date
        @issue.refresh_shift_subject
      end
    end
  end

  def controller_issues_edit_after_save(context={}) #runs after save on issue edit
  end


  #prevent edits ot time entries locked to sheets, and prevent creation of new entries when a user already has a non-draft sheet
  #def controller_timelog_edit_before_save(context={})
  #  if context[:time_entry].safe_to_edit?
  #  end
  #end
    #TODO reenable useful view hooks
    #render_on :view_layouts_base_html_head,
    #          :partial => 'hooks/redmine_scheduler/google'

    # render_on :view_issues_form_details_bottom, #this is how you attach stuff to views. you can also overwrite them by putting them in the /app/ tree of the plugin
    #           :partial => 'hooks/redmine_scheduler/extras'

    render_on :view_issues_show_description_bottom,
              :partial => 'hooks/redmine_scheduler/show_extras'

    render_on :view_welcome_index_left,
              :partial => 'hooks/redmine_scheduler/home_additions'
              
    render_on :view_layouts_base_html_head,
              :partial => 'hooks/redmine_scheduler/head'
              
    # render_on :view_timelog_edit_form_bottom, #this is how you attach stuff to views. you can also overwrite them by putting them in the /app/ tree of the plugin
    #           :partial => 'hooks/redmine_scheduler/timex'

    # render_on :view_projects_form,
    #           :partial => 'hooks/redmine_scheduler/project_form_extras'
    # render_on :view_users_form,
    #           :partial => 'hooks/redmine_scheduler/user_form_extras'
    # render_on :view_my_account,
    #           :partial => 'hooks/redmine_scheduler/user_form_extras'
end
