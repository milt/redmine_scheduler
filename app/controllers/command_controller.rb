class CommandController < ApplicationController
  unloadable

  def index
    @workgroups = User.current.workgroups
  end
end
