class FinesController < ApplicationController
  unloadable
  load_and_authorize_resource

  def index
    @paid = @fines.paid
    @unpaid = @fines.unpaid

    respond_to do |format|
      format.html
      format.js
    end
  end

  def new
  end

  def create
    if @fine.save
      flash[:notice] = "Fine successfully created."
      redirect_to @fine
    else
      flash[:warning] = "Fine was not saved."
      render action: "new"
    end
  end

  def show
  end

  def edit
  end

  def update
  end
end
