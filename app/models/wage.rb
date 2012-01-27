class Wage < ActiveRecord::Base
  unloadable
  has_many :users
  
end
