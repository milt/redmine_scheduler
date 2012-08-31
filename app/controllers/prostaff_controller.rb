class ProstaffController < ApplicationController
  unloadable


  def index
  end

  def student_levels
    @students = Group.stustaff.first.users.active
    @training_project = Project.find(:first, :conditions => "name = 'Training Project'")
  end
end
