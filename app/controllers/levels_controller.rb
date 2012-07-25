class LevelsController < ApplicationController
	unloadable

	before_filter :find_users


	#need to add additional levels?
	def index
		#@users = User.all
		@sorted_by_name = User.all.paginate(:page => params[:level_page], :per_page =>5, :order => 'name')
		@sorted_by_skill = User.all.paginate(:page => params[:level_page], :per_page => 5, :order => 'skill.desc')
		@sorted_by_level = User.all.paginate(:page => params[:level_page], :per_page => 5, :order => 'level.rating')
		@employee_selected = User.all		
	end

	def edit
		

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

	end

	def user_new_skill
		if params[:search]
      		user_id_from_firstname = User.all.select {|x| x.firstname == params[:search]}
    	else
    		
    	end	
	end

	private

	def find_users #find the users who aren't system users
	    @users = User.all.select {|u| u.id > 2 }
	end
end