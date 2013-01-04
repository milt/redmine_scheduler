class RepairsController < ApplicationController
  unloadable

  def index
    @repairs = Repair.all
  end

  def new
  end

  def create
    @repair = Repair.new(params[:repair])
    @repair.user = User.current

    if @repair.save
      flash[:notice] = 'Repair was successfully created.'
    else                                               
      flash[:warning] = 'Invalid Options... Try again!'
    end
  
    redirect_to :action => 'index'
  end

  def show
    @repair = Repair.find(params[:id])
  end
  
end