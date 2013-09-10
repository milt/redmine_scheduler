class Skillcat < ActiveRecord::Base #Skill categories
  unloadable
  has_many :skills, :dependent => :destroy #each category has many skills, and if the category is destroyed, so are the skills
  has_many :levels, :through => :skills
  validates :name, uniqueness: true #skill category names are unique
  default_scope :order => 'name ASC' #default sort is category name ascending
  attr_accessible :name, :descr
  #scope :auth_cat, lambda { { :conditions => ["name = ?", "Authorization"] } }
  scope :auth_cat, where( name: "Authorization" )
  #scope :skill_cat, lambda { { :conditions => ["name != ?", "Authorization"] } }
  scope :skill_cat, where( name: "General" )

  def auth?
  	if name == "Authorization"
  		return true
  	else
  		return false
  	end
  end
end
