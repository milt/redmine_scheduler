class Skillcat < ActiveRecord::Base #Skill categories
  unloadable
  has_many :skills, :dependent => :destroy #each category has many skills, and if the category is destroyed, so are the skills
  has_many :levels, :through => :skills
  validates_uniqueness_of :name #skill category names are unique
  default_scope :order => 'name ASC' #default sort is category name ascending
  attr_accessible :name, :descr
  named_scope :auth_cat, lambda { { :conditions => ["name = ?", "Authorization"] } }
  named_scope :skill_cat, lambda { { :conditions => ["name != ?", "Authorization"] } }

  def auth?
  	if name == "Authorization"
  		return true
  	else
  		return false
  	end
  end
end
