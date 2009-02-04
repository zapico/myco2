class EmissionsController < ApplicationController
  # GET /emissions/
  # GET /emissions.xml
  def index
    @user = User.find(session[:id])
    @emissions = @user.emissions.find(:all)
    @total = 0
    for emission in @emissions
      @total += emission.amount
    end
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @emissions }
    end
  end

  # GET /emissions/1
  # GET /emissions/1.xml
  def show
    @emission = Emission.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @emission }
    end
  end

  # GET /emissions/new
  # GET /emissions/new.xml
  def new
    @emission = Emission.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @emission }
    end
  end
    # GET /emissions/new_electricity
  def new_electricity
    @user = User.find(session[:id])
    @city = @user.city
    @source = Source.find(:first, :conditions => ["name = 'electricity' AND city_id = ?",@city.id])
    @emission = Emission.new
    
    respond_to do |format|
      format.html # new_electricity.html.erb
      format.xml  { render :xml => @emission }
    end
  end

  # GET /emissions/1/edit
  def edit
    @emission = Emission.find(params[:id])
  end

  # POST /emissions
  # POST /emissions.xml
  def create
    @emission = Emission.new(params[:emission])
    @emission.amount = @emission.amount * @emission.source.factor
    respond_to do |format|
      if @emission.save
        flash[:notice] = 'Emission was successfully created.'
        format.html { redirect_to(@emission) }
        format.xml  { render :xml => @emission, :status => :created, :location => @emission }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @emission.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /emissions/1
  # PUT /emissions/1.xml
  def update
    @emission = Emission.find(params[:id])

    respond_to do |format|
      if @emission.update_attributes(params[:emission])
        flash[:notice] = 'Emission was successfully updated.'
        format.html { redirect_to(@emission) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @emission.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /emissions/1
  # DELETE /emissions/1.xml
  def destroy
    @emission = Emission.find(params[:id])
    @emission.destroy

    respond_to do |format|
      format.html { redirect_to(emissions_url) }
      format.xml  { head :ok }
    end
  end
end
