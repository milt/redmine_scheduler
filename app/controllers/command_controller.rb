class CommandController < ApplicationController
  unloadable

  def index
    
    if params[:hours].present?
      @hours = params[:hours].to_f
    else
      @hours = 20
    end
    
    if params[:weeks].present?
      @weeks = params[:weeks].to_i
    else
      @weeks = 2
    end
    
    @workgroups = User.current.workgroups
  end
end
