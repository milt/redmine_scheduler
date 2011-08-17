class BookingController < ApplicationController
  unloadable


  def index
    #check for incoming search parameters, and instantiate an empty array if there are none.
    if params[:skill_ids].nil?
      @filter = []
    else
      @filter = params[:skill_ids]
    end
    
    @timeslots = Timeslot.all
    @skills = Skill.all
    @selskills= @skills.select {|s| @filter.include?(s.id.to_s)}
    @unbooked = @timeslots.select {|t| t.booking.nil? && (t.slot_date > Date.today)}
    @selslots = []
    
    
    @selskills.each do |skill|
      skill.timeslots.each do |slot|
        unless @selslots.include?(slot)
          @selslots << slot
        end
      end
    end      
  end
  
  def new
    begin
      @timeslot = Timeslot.find(params[:timeslot_id])
    rescue
      flash[:warning] = 'Could not find timeslot. Maybe someone else got it first?'
      redirect_to :action => "index"
    end
  end
  
  
  def book
    begin
      @timeslot = Timeslot.find(params[:timeslot_id])
    rescue
      flash[:warning] = 'Could not find timeslot. Maybe someone else got it first?'
      redirect_to :action => "index"
    end
    
    @booking = @timeslot.build_booking(params[:booking])
    
    respond_to do |format|
      if @booking.save
         flash[:notice] = 'Booking was successfully created.'
         format.html { redirect_to :action => "index" }
         format.xml  { render :xml => @booking, :status => :created,
                     :location => @booking }
      else                                               
         flash[:warning] = 'Invalid Options... Try again!'
         format.html { redirect_to :action => "index" }
         format.xml  { render :xml => @booking.errors,
                     :status => :unprocessable_entity }
      end
    end
  end
  
  
end
