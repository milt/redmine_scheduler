class WagesController < ApplicationController
  unloadable
  
  before_filter :find_users, :only => [:index, :edit]
  
  def index
    @wages = Wage.all
  end
  
  def edit #edit users assigned to a given wage
    @wage = Wage.find(params[:id])    
    @assigned = @users.select {|user| @wage.users.exists?(user)}
    @unassigned = @users.reject {|user| @wage.users.exists?(user)}
  end
  
  def assign #assign a wage to a given user
    @user = User.find(params[:user_id])
    @wages = Wage.all
    @assigned = @wage.select {|wage| @user.wage.exists?(wage)}
    @unassigned = @wage.reject {|wage| @user.wage.exists?(wage)}
  end
  
  def new
    @wage = Wage.new
  end
  
  def create
    @wage = Wage.new(params[:amount])
    
      respond_to do |format|
        if @wage.save
          flash[:notice] = 'Wage was successfully created'
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
  
  def update #edit a wage from user input
    @wage = Wage.find(params[:id])
    
    respond_to do |format|
      if @wage.update_attributes(params[:wage])
        flash[:notice] = 'wage was successfully updated.'
        format.html { redirect_to :action => 'index' }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @post.errors,
                    :status => :unprocessable_entity }
      end
    end
  end
  
  def destroy
    @wage = Wage.find(params[:id])
    @wage.destroy
    flash[:notice] = 'Wage deleted.'
    redirect_to :action => 'index'
  end
  
  def link #link a wage to a given user
    @wage = Wage.find(params[:id])
    @user = User.find(params[:user_id])
    @user.wage = @wage
    @user.save
    flash[:notice] = 'Wage assigned.'
    redirect_to :action => 'assign', :user_id => @user[:id]
  end
  
  def unlink #unlink a wage from a given user
    @wage = Wage.find(params[:id])
    @user = User.find(params[:user_id])
    @user.wage.delete(@wage)
    flash[:notice] = 'Wage unassigned.'
    redirect_to :action => 'assign', :user_id => @user[:id]
  end
  
  private
  
  def find_users #find the users who aren't system users
    @users = User.all.select {|u| u.id > 2 }
  end
end
