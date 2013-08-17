class FinesController < ApplicationController
  unloadable
  load_and_authorize_resource

  def index
    @paid = @fines.paid.search(params[:search]).page(params[:paid_page]).per(10)
    @unpaid = @fines.unpaid.search(params[:search]).page(params[:unpaid_page]).per(10)

    respond_to do |format|
      format.html
      format.js
    end
  end

  def new
    @fine = Fine.new
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
