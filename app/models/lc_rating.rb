class LcRating < ActiveRecord::Base
  unloadable

  # TODO might need to change user_patch.rb to reflect this
  belongs_to :user
  validates :rated_user_id,:rater_user_id,:issue_id, presence: true
  validates :rating, numericality: { 
    :only_integer => true, 
    :greater_than_or_equal_to => 0, 
    :less_than_or_equal_to => 10 }
  validates :comment, length: {maximum: 4096}

  # TODO add this after fixing lc_rating db create
  # validates :id, uniqueness: {scope: :shift_id, message: "Only one rating per shift per user??"}

  # order ratings by rating, hi->lo
  default_scope :order => 'rating DESC'

  # usage LcRating.for_user(User.find(__some_user_id__))
  scope :for_user, lambda {|u| { :conditions => { :rated_user_id => u.id } } }

  def user
    self.user
  end
end
