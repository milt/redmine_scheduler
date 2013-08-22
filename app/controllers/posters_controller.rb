class PostersController < ApplicationController
  unloadable
  load_and_authorize_resource


  def index
  end

  def new
  end

  def create
    @poster.user = User.current
    @poster.save_attachments(params[:attachments])
    if @poster.save
      flash[:notice] = "Poster order submitted."
      redirect_to @poster.issue
    else
      flash[:warning] = "Poster order could not be submitted. Please see errors below."
      render action: "new"
    end
  end

  def show
  end

  def settings
    @poster_settings = Setting.plugin_redmine_scheduler.select{|k| k.include?("poster_")}

    render json: @poster_settings
  end
end
