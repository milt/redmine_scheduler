class SkillsController < ApplicationController #define skills, assign them to users
  unloadable
  authorize_resource

  before_filter :find_skill, :only => [:edit, :update, :destroy, :delete]
  
  def index
    @skill = Skill.new
  end

  def edit
    #@skill = Skill.find(params[:id])
  end

  def show
  end

  def create #make a new skill from user input
    @skill = Skill.new(params[:skill])

    if @skill.save
      flash[:notice] = 'Skill was successfully created.'
    else                                               
      flash[:warning] = 'Invalid Options... Try again!'
    end
  
    redirect_to :action => 'index'
  end
  
  def update #edit a skill from user input
    if @skill.update_attributes(params[:skill])   #how does this line work?
      flash[:notice] = "Skill was successfully updated."
    else
      flash[:warning] = "An error has occurred when updating the skill!"
    end
    redirect_to :action => 'index'
  end
  
  def delete
    if @skill.delete
      flash[:notice] = "Skill deleted."
    else
      flash[:warning] = "An error has occurred when deleting the skill.."
    end
    redirect_to :action => 'index'
  end

  private
  
  def find_skill
    @skill = Skill.find(params[:id])
  end

end
