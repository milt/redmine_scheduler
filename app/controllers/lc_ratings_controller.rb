class LcRatingsController < ApplicationController
  unloadable

  def index
  	my_id = User.current.id
  	my_ratings = LcRating.where(rated_user_id:10)  #used for testing
    # my_ratings = LcRating.where(rated_user_id:my_id)
    @rating_display = display_ratings(my_ratings)
  end

  # action taken during rating
  def rate
	rating = LcRating.new(:rated_user_id=>params[:id])
    if rating.save
      flash[:notice] = 'Rating saved.'
    end
    redirect_to :action => 'index'
  end

  # storing ratings in an array of hashes
  def display_ratings(ratings)
  	rating_display = []

  	ratings.each do |rating|
  	  rater_fullname = User.find(rating.rater_user_id).firstname + ' ' + User.find(rating.rater_user_id).lastname
  	  display_hash = {:rater_fullname=>rater_fullname,:star_power=>rating.rating,:comment=>rating.comment}
  	  rating_display << display_hash
  	end

  	rating_display  #returned
  end
end
