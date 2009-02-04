class ElectricityusesController < ApplicationController
  # GET /electricityuses
  # GET /electricityuses.xml
  def index
    @electricityuses = Electricityuse.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @electricityuses }
    end
  end

  # GET /electricityuses/1
  # GET /electricityuses/1.xml
  def show
    @electricityuse = Electricityuse.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @electricityuse }
    end
  end

  # GET /electricityuses/new
  # GET /electricityuses/new.xml
  def new
    @electricityuse = Electricityuse.new
    @device = Device.find(params[:device])
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @electricityuse }
    end
  end

  # GET /electricityuses/1/edit
  def edit
    @electricityuse = Electricityuse.find(params[:id])
  end

  # POST /electricityuses
  # POST /electricityuses.xml
  def create
    @electricityuse = Electricityuse.new(params[:electricityuse])

    respond_to do |format|
      if @electricityuse.save
        flash[:notice] = 'Electricityuse was successfully created.'
        format.html { redirect_to(@electricityuse) }
        format.xml  { render :xml => @electricityuse, :status => :created, :location => @electricityuse }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @electricityuse.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /electricityuses/1
  # PUT /electricityuses/1.xml
  def update
    @electricityuse = Electricityuse.find(params[:id])

    respond_to do |format|
      if @electricityuse.update_attributes(params[:electricityuse])
        flash[:notice] = 'Electricityuse was successfully updated.'
        format.html { redirect_to(@electricityuse) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @electricityuse.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /electricityuses/1
  # DELETE /electricityuses/1.xml
  def destroy
    @electricityuse = Electricityuse.find(params[:id])
    @electricityuse.destroy

    respond_to do |format|
      format.html { redirect_to(electricityuses_url) }
      format.xml  { head :ok }
    end
  end
end
