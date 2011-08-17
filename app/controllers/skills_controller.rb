class SkillsController < ApplicationController
  unloadable

  #before_filter :find_project, :authorize, :only => :index
  
  def index
    @skills = Skill.all
    @users = User.all.select {|u| u.id > 2 }
    @skillcats = Skillcat.all
  end

  def edit
    @skill = Skill.find(params[:id])    
    @users = User.all.select {|u| u.id > 2 }
    @assigned = @users.select {|user| @skill.users.exists?(user)}
    @unassigned = @users.reject {|user| @skill.users.exists?(user)}
  end
  
  def assign
    @user = User.find(params[:user_id])
    @skills = Skill.all
    @assigned = @skills.select {|skill| @user.skills.exists?(skill)}
    @unassigned = @skills.reject {|skill| @user.skills.exists?(skill)}
  end

  def new
    @skill = Skill.new
  end

  def create
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
  
  def update
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
  
  def link
    @skill = Skill.find(params[:id])
    @user = User.find(params[:user_id])
    @user.skills << @skill
    flash[:notice] = 'Skill assigned.'
    redirect_to :action => 'assign', :user_id => @user[:id]
  end
  
  def unlink
    @skill = Skill.find(params[:id])
    @user = User.find(params[:user_id])
    @user.skills.delete(@skill)
    flash[:notice] = 'Skill unassigned.'
    redirect_to :action => 'assign', :user_id => @user[:id]
  end
  
  #private
  
  #def find_project
  #  # @project variable must be set before calling the authorize filter
  #  @project = Project.find(params[:project_id])
  #end
end
