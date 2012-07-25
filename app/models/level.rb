class Level < ActiveRecord::Base
	belongs_to :skill
	belongs_to :user
	validates_presence_of :rating
	validates_numericality_of :rating, 
		:only_integer => true, 
		:greater_than_or_equal_to => 1, 
		:less_than_or_equal_to => 3
	validates_uniqueness_of :skill_id, :scope => :user_id, 
		:message => "Only one skill level per skill per user."
end