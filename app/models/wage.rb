class Wage < ActiveRecord::Base
  unloadable
  has_one :user
  default_scope :order => 'amount ASC'
  attr_accessible :amount
  
end
