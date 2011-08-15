class Skillcat < ActiveRecord::Base
  unloadable
  has_many :skills, :dependent => :destroy
  validates_uniqueness_of :name
end
