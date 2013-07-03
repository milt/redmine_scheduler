class Fine < ActiveRecord::Base
  unloadable
  belongs_to :repair
end
