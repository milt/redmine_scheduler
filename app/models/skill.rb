class Skill < ActiveRecord::Base
  has_and_belongs_to_many :users, :uniq => true
  belongs_to :skillcat
  validates_uniqueness_of :name

end
