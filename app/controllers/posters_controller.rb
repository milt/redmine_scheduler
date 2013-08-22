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
    if params[:attachments]
      @poster.file_name = params[:attachments]["1"]["filename"]
    end
    if @poster.save
      flash[:notice] = "Poster order submitted."
      redirect_to @poster.issue
    else
      flash[:warning] = "Poster order could not be submitted. Please see errors below."
      render action: "new"
    end
  end

  def show
    respond_to do |format|
      format.html
      format.pdf { render :layout => false }
    end
  end

  def settings
    @poster_settings = Setting.plugin_redmine_scheduler.select{|k| k.include?("poster_")}

    render json: @poster_settings
  end
end
