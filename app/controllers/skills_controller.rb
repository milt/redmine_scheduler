class SkillsController < ApplicationController
  unloadable

  def index
    @skills = Skill.all
    @users = User.all
	end
  
  def assign
    @user = User.find(params[:user_id])
    @skills = Skill.all
    @assigned = []
    @unassigned = []

    @skills.each do |skill|
      if @user.skills.exists?(skill)
        @assigned << skill
      else
        @unassigned << skill
      end
    end
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
          format.html { redirect_to :action => "index" }
          format.xml  { render :xml => @skill.errors,
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
  
end
