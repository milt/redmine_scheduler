class LevelsController < ApplicationController
	unloadable


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
		current_level = level.find(:condition => ['user_id LIKE?', User.current.id])
		changed_level = params[:changed_level]
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

	def user_new_skill
		if params[:search]
      		user_id_from_firstname = User.all.select {|x| x.firstname == params[:search]}
    	else
    		
    	end	
	end

	private

end