# Controller for commuting emissions
# They can be either from PEIR or manually added
# 
# Jorge L. Zapico 
# KTH, Centre for Sustainable Communications, 2009
# www.sustainablecommunications.org

class PeirEmissionsController < ApplicationController

  def commuting
    @user = User.find(session[:id])
    @other = @user.peir_emissions.find(:all, :conditions => ['habit = 0'])
    @habits = @user.peir_emissions.find(:all, :conditions => ['habit != 0'])
    all = @user.peir_emissions.find(:all)
    @total = 0
    @month = 0
    @year = 0
    for emission in all do
      @total += emission.co2
      if emission.date.year == Time.now.year then @year += emission.co2 end
      if (emission.date.month == Time.now.month &&  emission.date.year == Time.now.year)then @month += emission.co2 end
    end
    
  end
  
  # Update 
  def daily_update
    @user = User.find(params[:id])
    @habits = @user.peir_emissions.find(:all, :conditions => ['habit != 0'])
    for emission in habit do
      case emission.habit
      when 1
        s = "daily"
        
      when 2
        s= "every weekday"
      when 3
        s = "once a week"
      end
      
      @total += emission.co2
      if emission.date.year == Time.now.year then @year += emission.co2 end
      if (emission.date.month == Time.now.month &&  emission.date.year == Time.now.year)then @month += emission.co2 end
    end
    
  end

  # Create a new emission manually
  def new
    @user = User.find(session[:id])
    @peir_emission = PeirEmission.new
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @source }
    end
  end

  def edit
    @peir_emission = PeirEmission.find(params[:id])
    @user = User.find(session[:id])
  end

  def create
    @peir_emission = PeirEmission.new(params[:peir_emission])
    #Calculate the CO2
    @peir_emission.co2 = @peir_emission.km * @peir_emission.source.factor
    respond_to do |format|
    # Save
    if @peir_emission.save
        flash[:notice] = 'Source was successfully created.'
        format.html { redirect_to(@peir_emission) }
        format.xml  { render :xml => @peir_emission, :status => :created, :location => @peir_emission }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @peir_emission.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
     @peir_emission = PeirEmission.find(params[:id])
     respond_to do |format|
      #Recalculate the CO2
       @peir_emission.co2 = @peir_emission.km * @peir_emission.source.factor
     if @peir_emission.update_attributes(params[:peir_emission])
        flash[:notice] = 'Source was successfully updated.'
        format.html { redirect_to(@peir_emission) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @source.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @peir_emission = PeirEmission.find(params[:id])
    @peir_emission.destroy

    respond_to do |format|
      format.html { redirect_to(sources_url) }
      format.xml  { head :ok }
    end
  end
  

end
