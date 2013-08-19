class ProstaffController < ApplicationController
  unloadable

  def index
    authorize! :index, :prostaff

    @reminders = Reminder.all
  end

  def student_levels
    authorize! :student_levels, :prostaff
    @students = Group.stustaff.first.users.active
    @training_project = Project.find(:first, :conditions => "name = 'Training Project'")
    @goals_by_student = Issue.goals.open.group_by(&:assigned_to)
  end
end
