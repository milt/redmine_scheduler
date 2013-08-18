class Poster < ActiveRecord::Base
  unloadable
  belongs_to :user
  belongs_to :issue
end
