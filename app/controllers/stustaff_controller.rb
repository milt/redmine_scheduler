class StustaffController < ApplicationController
  unloadable


  def index
  	@allshiftstoday = Issue.today.open.fdshift
    @todayshifts = Issue.today.open.fdshift.foruser(User.current)
    @alllcshiftstoday = Issue.today.open.lcshift
    @todaylcshifts = Issue.today.open.lcshift.foruser(User.current)
    @mytasks = Issue.open.tasks.foruser(User.current)
    @mygoals = Issue.open.goals.foruser(User.current)
    @mywatches = Issue.visible.watched_by(User.current)  #this line should returns an array of watched issues for current user
    @taskpool = Issue.find(:all,:conditions=>{:assigned_to_id=>nil})
  end
end
