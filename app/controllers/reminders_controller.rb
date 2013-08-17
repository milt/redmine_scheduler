class RemindersController < ApplicationController
  unloadable
  load_and_authorize_resource

  def index
    @reminder = Reminder.new

    respond_to do |format|
      format.html
      format.js
    end
  end

  def create
  end
  
end
