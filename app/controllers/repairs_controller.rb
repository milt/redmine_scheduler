class RepairsController < ApplicationController
  unloadable

  before_filter :role_check

  def index
    @repairs = Repair.all
  end

  def new
    if params[:issue_id]
      @issue = Issue.find(params[:issue_id].to_i)
    end
    @repair = Repair.new
  end

  def create
    @repair = Repair.new(params[:repair])
    @repair.user = User.current
    if params[:issue_id]
      @repair.issue = Issue.find(params[:issue_id].to_s)
    end

    if @repair.save
      if @repair.patron_name.present?
        flash[:notice] = "Repair created. Please remember to print an agreement for the patron!"
      else
        flash[:notice] = 'Repair was successfully created.'
      end
      redirect_to :action => 'show', :id => @repair
    else                                               
      flash[:warning] = 'Invalid Options... Try again!'
      redirect_to :action => 'new'
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

  private

  def role_check
    if User.current.anonymous?
      render_403
      return false
    end
    true
  end
  
end