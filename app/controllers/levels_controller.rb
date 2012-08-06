class LevelsController < ApplicationController
  unloadable
  before_filter :role_check, :except => :my_levels


  #need to add additional levels?
  def index
    @users = Group.stustaff.first.users
    @skills = Skill.all
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
      skill = Skill.find(params[:level][:skill_id].to_i)
      rating = params[:level][:rating].to_i

      @level = Level.new(:user => user, :skill => skill, :rating => rating)
      if @level.save
        flash[:notice] = 'Level was successfully created.'
        redirect_to :action => "index"
      else                                               
        flash[:warning] = 'Invalid Options... Try again!'
        redirect_to :action => "index"
      end
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
    @levels = Level.for_user(User.current)
  end

  private

  def role_check
    if !User.current.is_admstaff?
      render_403
      return false
    end
    true
  end
end
