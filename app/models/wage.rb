class Wage < ActiveRecord::Base
  unloadable
  has_many :users
  default_scope :order => 'amount ASC'
  attr_accessible :amount
  
end
