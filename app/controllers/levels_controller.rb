class LevelsController < ApplicationController
  unloadable
  before_filter :role_check, :except => :my_levels

  def index
    @users = Group.stustaff.first.users.active
    @skills = Skill.all
  
    @skillcats = Skillcat.all.sort_by(&:name)  #sorts skill categories by name
    @skills_list = []

    @skills_list = skill_sorted_create
    @goals = Issue.goals.feedback
  end

  def edit
    @level = Level.find(params[:id])
  end

  #purpose: used to reassign a user to another skill level
  #calling by to pass in the user to be changed
  #view paramters passed in: level to be changed to
  #lists all the user's skills and what level is the user at

  def update
    @level = Level.find(params[:id])
      rating = params[:level][:rating].to_i
      @level.rating = rating
      if @level.save
        flash[:notice] = 'Level was successfully updated.'
        redirect_to :action => "index"
      else                                               
        flash[:warning] = 'Invalid Options... Try again!'
        redirect_to :action => "index"
      end
  end

  def new
  end

  def create
      user = User.find(params[:level][:user_id].to_i)
      #skill = Skill.find(params[:skill_id])
      skills = []

      #rating = params[:level][:rating].to_i
      rating = 1  #starting with all first levels, can change later with edit

      params[:skill_id].each do |skill|
        #@level = Level.new(:user => user, :skill => skill, :rating => rating)
        level = Level.new(:user => user, :skill => Skill.find(skill), :rating => rating)
        #if @level.save
        if level.save
          flash[:notice] = 'Level was successfully created.'
          #redirect_to :action => "index"
        else                                               
          flash[:warning] = 'Invalid Options... Try again!'
          #redirect_to :action => "index"
        end
      end
      redirect_to :action => "index"
  end

    def delete
      @level = Level.find(params[:id])
      if @level.delete
        flash[:notice] = "Level was successfully deleted."
        redirect_to :action => "index"
      else
        flash[:warning] = 'Could not Delete!'
        redirect_to :action => "index"
      end
    end

  def user_new_skill
    if params[:search]
          user_id_from_firstname = User.all.select {|x| x.firstname == params[:search]}
      else
        
      end 
  end

  def my_levels
    @levels = Level.for_user(User.current).group_by(&:skillcat)
  end

  private

  def skill_sorted_create
    skill_arr = []
    @skillcats.each do |cat|
      skill_arr << ["", nil]
      skill_arr << ["-------" + cat.name + "-------", nil]
      skills_sorted = cat.skills.sort_by(&:name)

      skills_sorted.each do |skill|
        skill_arr << [skill.name, skill.id] 
      end
    end
    skill_arr
    
  end

  def role_check
    if !User.current.is_admstaff?
      render_403
      return false
    end
    true
  end
end
