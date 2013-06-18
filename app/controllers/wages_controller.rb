class WagesController < ApplicationController
  unloadable
  load_and_authorize_resource
  
  before_filter :require_admstaff
  before_filter :find_users, :only => :index
  
  def index
    @wage = Wage.new
  end
  
  def edit
  end
  
  def create #make a new wage from user input
    @user = User.find(params[:user_id])
    @wage = @user.build_wage(params[:wage])

      respond_to do |format|
        if @wage.save
          flash[:notice] = 'Wage was successfully created.'
          format.html { redirect_to :action => "index" }
          format.xml  { render :xml => @wage, :status => :created,
                      :location => @wage }
        else                                               
          flash[:warning] = 'Invalid Options... Try again!'
          format.html { redirect_to :action => "index" }
          format.xml  { render :xml => @wage.errors,
                      :status => :unprocessable_entity }
        end
     end
  end
  
  def update
    @wage = Wage.find(params[:id])
    @wage.amount = params[:wage][:amount]

    respond_to do |format|
      if @wage.save
        flash[:notice] = 'Wage was successfully updated.'
        format.html { redirect_to :action => "index" }
        format.xml  { render :xml => @wage, :status => :created,
                    :location => @wage }
      else                                               
        flash[:warning] = 'Invalid Options... Try again!'
        format.html { redirect_to :action => "index" }
        format.xml  { render :xml => @wage.errors,
                    :status => :unprocessable_entity }
      end
    end
  end
  
  private
  
  def require_admstaff
    return unless require_login
    if !User.current.is_admstaff?
      render_403
      return false
    end
    true
  end

  # def find_wages
  #   @wages = Wage.all
  # end
  
  def find_users #find the student staff
    @users = Group.stustaff.first.users.active
    @users = @users.sort_by {|u| u.lastname }
  end
end
