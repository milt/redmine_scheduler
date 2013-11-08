class Printing3dsController < ApplicationController
  unloadable
  load_and_authorize_resource

  def index
  end

  def new
  end

  def create
    @printing3d.user = User.current
    @printing3d.dropoff = DateTime.now
    if params[:attachments]
      @printing3d.save_attachments(params[:attachments])
      @printing3d.file_name = params[:attachments][params[:attachments].keys.first]["filename"]
    end
    if @printing3d.save
      flash[:notice] = "3D Printing order submitted."
      redirect_to @printing3d.issue
    else
      flash[:warning] = "3D Printing order could not be submitted. Please see errors below."
      render action: "new"
    end
  end

  def show
    respond_to do |format|
      format.html
      format.pdf { render :layout => false }
    end
  end

  # check init.rb for detailed setting preferences
  def settings
    @printing3d_settings = Setting.plugin_redmine_scheduler.select{|k| k.include?("printing3d_")}

    render json: @printing3d_settings
  end
end
