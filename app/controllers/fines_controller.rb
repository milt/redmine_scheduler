class FinesController < ApplicationController
  unloadable
  load_and_authorize_resource
  before_filter :paid_check, only: [:edit, :update, :pay]

  def index
    @paid = @fines.paid.search(params[:search]).page(params[:paid_page]).per(20)
    @unpaid = @fines.unpaid.search(params[:search]).page(params[:unpaid_page]).per(20)

    respond_to do |format|
      format.html
      format.js
    end
  end

  def new
    if params[:repair_id]
      @repair = Repair.find(params[:repair_id])
      @fine.patron_name = @repair.patron_name
      @fine.patron_phone = @repair.patron_phone
      @fine.patron_email = @repair.patron_email
      @fine.patron_jhed = @repair.patron_jhed
      @fine.repair = @repair
    end
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
    if @fine.update_attributes(params[:fine])
      flash[:notice] = "Fine successfully updated."
      redirect_to @fine
    else
      flash[:warning] = "Fine was not saved."
      render action: 'edit'
    end
  end

  def pay
    @fine.payment_method = params[:fine][:payment_method]
    @fine.paid = DateTime.now

    if @fine.save
      flash[:notice] = "Fine paid via #{@fine.payment_method} at #{@fine.paid}"
      redirect_to @fine
    else
      flash[:warning] = "Payment Failed!"
      redirect_to @fine
    end
  end

  private

  def paid_check
    if @fine.paid?
      flash[:warning] = "Cannot edit or pay again if fine is already paid!"
      redirect_to @fine
    end
  end
end
