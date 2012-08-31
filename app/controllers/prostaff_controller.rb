class ProstaffController < ApplicationController
  unloadable


  def index
  end

  def student_levels
    @students = Group.stustaff.first.users
  end
end
