class SkillcatsController < ApplicationController
  unloadable


  def index
    @skillcats = Skillcat.all
  end

  def new
    @skill = Skillcat.new
  end

  def create
    @skillcat = Skillcat.new(params[:skillcat])

    respond_to do |format|
      if @skillcat.save
        flash[:notice] = 'Skill Category was successfully created.'
        format.html { redirect_to :action => "index" }
        format.xml  { render :xml => @skillcat, :status => :created,
                    :location => @skillcat }
      else                                               
        flash[:warning] = 'There is already a skill category of that name!'
        format.html { redirect_to :action => "index" }
        format.xml  { render :xml => @skillcat.errors,
                    :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @skill = Skillcat.find(params[:id])
    @skill.destroy
    flash[:notice] = 'Skill Category deleted.'
    redirect_to :action => 'index'
  end
end
