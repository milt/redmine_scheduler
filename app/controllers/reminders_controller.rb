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
    @reminder = Reminder.new(params[:reminder])
    @reminder.user = User.current

    if @reminder.save
      flash[:notice] = "Reminder saved."
      redirect_to action: 'index'
    else
      flash[:warning] = "Reminder was not saved."
      redirect_to action: 'index'
    end
  end
  
  def destroy
    @reminder.destroy

    respond_to do |format|
      format.html {redirect_to reminders_path}
      format.js
    end
  end


end
