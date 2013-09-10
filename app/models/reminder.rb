class Reminder < ActiveRecord::Base
  unloadable
  belongs_to :user
end
