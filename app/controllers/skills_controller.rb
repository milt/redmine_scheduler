class SkillsController < ApplicationController #define skills, assign them to users
  unloadable

  before_filter :find_users, :only => [:index, :edit] #finds users for skill assignment
  
  def index #index and manage skills
    @skills = Skill.all
    @skillcats = Skillcat.all
    logger.info "the skill index page is showing"
  end

  def edit #edit users assigned to a given skill
    @skill = Skill.find(params[:id])    
    @assigned = @users.select {|user| @skill.users.exists?(user)}
    @unassigned = @users.reject {|user| @skill.users.exists?(user)}
  end
  
  def assign #assign a skill to a given user
    @user = User.find(params[:user_id])
    @skills = Skill.all
    @assigned = @skills.select {|skill| @user.skills.exists?(skill)}
    @unassigned = @skills.reject {|skill| @user.skills.exists?(skill)}
  end

  def new #new skill on bad params
    @skill = Skill.new
  end

  def create #make a new skill from user input
    @skill = Skill.new(params[:skill])

      respond_to do |format|
        if @skill.save
          flash[:notice] = 'Skill was successfully created.'
          format.html { redirect_to :action => "index" }
          format.xml  { render :xml => @skill, :status => :created,
                      :location => @skill }
        else                                               
          flash[:warning] = 'Invalid Options... Try again!'
          format.html { redirect_to :action => "index" }
          format.xml  { render :xml => @skill.errors,
                      :status => :unprocessable_entity }
        end
     end
  end
  
  def update #edit a skill from user input
    @skill = Skill.find(params[:id])
    
    respond_to do |format|
      if @skill.update_attributes(params[:skill])
        flash[:notice] = 'Skill was successfully updated.'
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
    @skill = Skill.find(params[:id])
    @skill.destroy
    flash[:notice] = 'Skill deleted.'
    redirect_to :action => 'index'
  end
  
  def link #link a given skill to a given user
    @skill = Skill.find(params[:id])
    @user = User.find(params[:user_id])
    @user.skills << @skill
    flash[:notice] = 'Skill assigned.'
    redirect_to :action => 'assign', :user_id => @user[:id]
  end
  
  def unlink #unlink a given skill from a given user
    @skill = Skill.find(params[:id])
    @user = User.find(params[:user_id])
    @user.skills.delete(@skill)
    flash[:notice] = 'Skill unassigned.'
    redirect_to :action => 'assign', :user_id => @user[:id]
  end
  
  private
  
  def find_users #find the users who aren't system users
    @users = User.all.select {|u| u.id > 2 }
  end
end
