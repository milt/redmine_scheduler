class PostersController < ApplicationController
  unloadable
  load_and_authorize_resource


  def index
  end

  def new
  end

  def create
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
end
