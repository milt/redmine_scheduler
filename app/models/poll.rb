class Poll < ActiveRecord::Base
	unloadable
	
	def vote(answer)
    	increment(answer == 'yes' ? :yes : :no)
  	end
end
