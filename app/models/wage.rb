class Wage < ActiveRecord::Base
  unloadable
  has_one :user
  monetize :amount_cents
  default_scope :order => 'amount_cents ASC'
  attr_accessible :amount
  
end
