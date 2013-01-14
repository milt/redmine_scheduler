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
      if @repair.patron_name.present?
        redirect_to :action => 'show', :id => @repair, :format => :pdf
      else
        redirect_to :controller => 'issues', :action => 'show', :id => @repair.issue_id
      end
    else                                               
      flash[:warning] = 'Invalid Options... Try again!'
    end
  end

  def show
    @repair = Repair.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      #format.xml  { render :xml => @book }
      format.pdf { render :layout => false }
    end
  end
  
end