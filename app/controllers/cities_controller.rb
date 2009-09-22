class CitiesController < ApplicationController
  before_filter :authorize_admin, :only => [:new, :destroy, :edit]  
 
  # GET /cities
  # GET /cities.xml
  def index
    @cities = City.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @cities }
    end
  end

  # Public homepage
  def info
      
      
      # Information of total year emissions from plane
      @plane = 0
      source = Source.find(4)
      dopplr = source.dopplr_emissions.find(:all, :conditions => ["YEAR(date) = ?",Time.now.year ]) 
      source2 = Source.find(3)
      dopplr2 = source2.dopplr_emissions.find(:all, :conditions => ["YEAR(date) = ?",Time.now.year ])
      dopplr.each do |d|
        @plane += d.co2
      end
      dopplr2.each do |c|
        @plane += c.co2
      end
      
      # Information of total year emissions from train
      @train = 0
      source = Source.find(5)
      train = source.dopplr_emissions.find(:all, :conditions => ["YEAR(date) = ?",Time.now.year ]) 
      source2 = Source.find(14)
      train2 = source2.emissions.find(:all, :conditions => ["YEAR(date) = ?",Time.now.year ])
      train.each do |d|
        @train += d.co2
      end
      train2.each do |c|
        @train += c.co2
      end
      
      # Information of total year emissions
      @total = 0
      dopplr = DopplrEmission.find(:all, :conditions => ["YEAR(date) = ?",Time.now.year ]) 
      commuting = PeirEmission.find(:all, :conditions => ["YEAR(date) = ?",Time.now.year ]) 
      emmisions = Emission.find(:all, :conditions => ["YEAR(date) = ?",Time.now.year ]) 
      dopplr.each do |d|
        @total += d.co2
      end
      commuting.each do |c|
        @total += c.co2
      end
      emmisions.each do |e|
        @total += e.co2
      end  
  end
  
  
  # GET /cities/1
  # GET /cities/1.xml
  def show
    @city = City.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @city }
    end
  end

  # GET /cities/new
  # GET /cities/new.xml
  def new
    @city = City.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @city }
    end
  end

  # GET /cities/1/edit
  def edit
    @city = City.find(params[:id])
  end

  # POST /cities
  # POST /cities.xml
  def create
    @city = City.new(params[:city])

    respond_to do |format|
      if @city.save
        flash[:notice] = 'City was successfully created.'
        format.html { redirect_to(@city) }
        format.xml  { render :xml => @city, :status => :created, :location => @city }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @city.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /cities/1
  # PUT /cities/1.xml
  def update
    @city = City.find(params[:id])

    respond_to do |format|
      if @city.update_attributes(params[:city])
        flash[:notice] = 'City was successfully updated.'
        format.html { redirect_to(@city) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @city.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /cities/1
  # DELETE /cities/1.xml
  def destroy
    @city = City.find(params[:id])
    @city.destroy

    respond_to do |format|
      format.html { redirect_to(cities_url) }
      format.xml  { head :ok }
    end
  end
end
