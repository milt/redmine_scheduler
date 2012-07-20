class LevelsController < ApplicationController
  unloadable

  before_filter :find_users

  def index
    
  end

  private

  def find_users #find the users who aren't system users
    @users = User.all.select {|u| u.id > 2 }
  end
end