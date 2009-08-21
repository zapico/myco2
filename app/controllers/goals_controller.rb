class GoalsController < ApplicationController
  # GET /goals
  # GET /goals.xml
  def index
    
    @user = User.find(session[:id])
    @goals = @user.goals
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @goals }
    end
  end

  # GET /goals/1
  # GET /goals/1.xml
  def show
    @goal = Goal.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @goal }
    end
  end

  # GET /goals/new
  # GET /goals/new.xml
  def new
    @goal = Goal.new
    @goal.goal_id = params[:goal_id]
    @goal.date_started = Date.today
    @goal.user_id = User.find(session[:id]).id
    
    case params[:goal_id]
      when '1'
        @goal.description = "Bike one day to work this week"
      when "2"
        @goal.description = "Do not fly in two months"
      when "3"
        @goal.description = "Reduce my carbon dioxide emissions a 20% from my actual baseline"
        @goal.co2 = 100
      when "4"
        @goal.description = "Reach or keep a sustainable level of emissions"
        @goal.limit = 200
      else
        @goal.description = "upss"
    end
    respond_to do |format|
      if @goal.save
      format.html # new.html.erb
      format.xml  { render :xml => @goal }
      end
    end
  end

  # GET /goals/1/edit
  def edit
    @goal = Goal.find(params[:id])
  end

  # POST /goals
  # POST /goals.xml
  def create
    @goal = Goal.new(params[:goal])

    respond_to do |format|
      if @goal.save
        flash[:notice] = 'Goal was successfully created.'
        format.html { redirect_to :action => "index" }
        format.xml  { render :xml => @goal, :status => :created, :location => @goal }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @goal.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /goals/1
  # PUT /goals/1.xml
  def update
    @goal = Goal.find(params[:id])

    respond_to do |format|
      if @goal.update_attributes(params[:goal])
        flash[:notice] = 'Goal was successfully updated.'
        format.html { redirect_to(@goal) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @goal.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /goals/1
  # DELETE /goals/1.xml
  def destroy
    @goal = Goal.find(params[:id])
    @goal.destroy

    respond_to do |format|
      format.html { redirect_to(goals_url) }
      format.xml  { head :ok }
    end
  end
end
