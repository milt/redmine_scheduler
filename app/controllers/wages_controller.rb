class WagesController < ApplicationController
  unloadable
  
  before_filter :require_admin, :find_wages, :find_users
  
  def index
  end
  
  def edit
  end
  
  def create #make a new skill from user input
    @wage = Wage.new(params[:wage])

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
  
  def change
    @user = User.find(params[:user][:id])
    @wage = Wage.find(params[:user][:wage_id])
    @user.wage = @wage
    @user.save
    flash[:notice] = 'Wage assigned.'
    redirect_to :action => 'index'
  end
  
  private
  
  def find_wages
    @wages = Wage.all
  end
  
  def find_users #find the users who aren't system users
    @users = User.all.select {|u| u.id > 2 }
    @users = @users.sort_by {|u| u.lastname }
  end
end
