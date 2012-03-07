class Skillcat < ActiveRecord::Base #Skill categories
  unloadable
  has_many :skills, :dependent => :destroy #each category has many skills, and if the category is destroyed, so are the skills
  validates_uniqueness_of :name #skill category names are unique
  default_scope :order => 'name ASC' #default sort is category name ascending
  attr_accessible :name, :descr
  
end
