class Skillcat < ActiveRecord::Base
  unloadable
  has_many :skills
  validates_uniqueness_of :name
end
