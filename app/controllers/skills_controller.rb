class SkillsController < ApplicationController
  unloadable

  def index
    @skills = Skill.all
    @users = User.all
	end
  
  def assign
    @user = User.find(params[:user_id])
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
          flash[:warning] = 'There is already a skill of that name!'
          format.html { render :action => "new" }
          format.xml  { render :xml => @skill.errors,
                      :status => :unprocessable_entity }
        end
     end
  end
  
  def delete
    @skill = Skill.find(params[:id])

  end
  
  def destroy
    @skill = Skill.find(params[:id])
    @skill.destroy
    redirect_to :action => 'index'
  end
  
  def unlink
    @skill = Skill.find(params[:id])
    @user = User.find(params[:user_id])
    @user.skills.delete(@skill)
    redirect_to :action => 'assign'
  end
  
end
