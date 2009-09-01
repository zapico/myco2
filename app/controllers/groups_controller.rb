# Controller for groups
#
# Jorge L. Zapico 
# KTH, Centre for Sustainable Communications, 2009
# www.sustainablecommunications.org

class GroupsController < ApplicationController
  before_filter :authorize, :only => [:emissions]
  before_filter :authorize_admin, :only => [:new, :edit, :destroy]

  # GET /groups
  # GET /groups.xml
  def index
    @groups = Group.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @groups }
    end
  end

  # GET /groups/1
  # GET /groups/1.xml
  # Main page for the group
  def show
    @group = Group.find(params[:id])
    @year = 0
    @month = 0
    @total = 0
    
    for emission in @group.dopplr_emissions
        @total += emission.co2
        if emission.date.year == Time.now.year then @year += emission.co2 end
        if (emission.date.month == Time.now.month &&  emission.date.year == Time.now.year)then @month += emission.co2 end
    end
    
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @group }
    end
  end
  
  # Detailed list of group emissions
  def emissions
    @group = Group.find(params[:id])
    @dopplremissions = @group.dopplr_emissions
  end
  
   # Join the active user to the group
   def join
    group = Group.find(params[:id])
	  thisuser = User.find(session[:id])
	  group.users<<thisuser
    redirect_to :action => 'show', :id => group

  end
  

  # GET /groups/new
  # GET /groups/new.xml
  def new
    @group = Group.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @group }
    end
  end

  # GET /groups/1/edit
  def edit
    @group = Group.find(params[:id])
  end

  # POST /groups
  # POST /groups.xml
  def create
    @group = Group.new(params[:group])

    respond_to do |format|
      if @group.save
        flash[:notice] = 'Group was successfully created.'
        format.html { redirect_to(@group) }
        format.xml  { render :xml => @group, :status => :created, :location => @group }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @group.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /groups/1
  # PUT /groups/1.xml
  def update
    @group = Group.find(params[:id])

    respond_to do |format|
      if @group.update_attributes(params[:group])
        flash[:notice] = 'Group was successfully updated.'
        format.html { redirect_to(@group) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @group.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /groups/1
  # DELETE /groups/1.xml
  def destroy
    @group = Group.find(params[:id])
    @group.destroy

    respond_to do |format|
      format.html { redirect_to(groups_url) }
      format.xml  { head :ok }
    end
  end
end
