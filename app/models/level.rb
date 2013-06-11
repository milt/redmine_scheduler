class Level < ActiveRecord::Base
  belongs_to :skill, :include => :skillcat
  belongs_to :user
  validates :rating, presence: true
  validates :rating, numericality: { 
    :only_integer => true, 
    :greater_than_or_equal_to => 1, 
    :less_than_or_equal_to => 3 }
  validates :skill_id, uniqueness: {scope: :user_id, message: "Only one skill level per skill per user."}
  scope :for_user, lambda {|u| { :conditions => { :user_id => u.id } } }

  def skillcat
    self.skill.skillcat
  end
end
