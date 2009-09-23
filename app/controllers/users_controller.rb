# Controller for user profiles
#
# Jorge L. Zapico 
# KTH, Centre for Sustainable Communications, 2009
# www.persuasiveservices.org

class UsersController < ApplicationController
  before_filter :authorize, :only => [:edit, :destroy, :account, :changepassword, :profile]
  before_filter :authorize_admin, :only => [:list, :delete, :resetpassword, :adminpasswords, :editadmin]
  
    def login
      reset_session
      session[:id] = nil
      if request.post?
          user = User.login(params[:email], params[:password])
          if user
              session[:id] = user.id
              redirect_to(:action => "profile")
          else
             flash[:notice] = "Invalid user/password combination"
          end
        end
  end
  


  def logout
    session[:id] = nil
    reset_session
    flash[:message] = 'logged out'
    redirect_to :action => 'login'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }


  
  def delete
    User.find(params[:id]).destroy
    redirect_to :action => 'adminpasswords'
  end
  
  # Create a new user
  def new
    @user = User.new(params[:user])
    if request.post? and @user.save
      flash[:notice] = 'User was successfully created.'
      redirect_to :action => 'login'
    else
      render :action => 'new'
    end
  end

  # Editing your own profile
  def edit
      flash[:notice] = ""
      @user = User.find(session[:id])
      @cities = City.find(:all)
      if request.post? and @user.update_attributes(params[:user])
              redirect_to :action => 'profile'
      end
  end
  
  # Edit page for admin
  def editadmin
      flash[:notice] = ""
      @user = User.find(params[:id])
      @cities = City.find(:all)
      if request.post? and @user.update_attributes(params[:user])
              redirect_to :action => 'list'
      end
  end
  
  def adminpasswords
  end
  
  # Index showing all users
  def index
    @users = User.find(:all, :order => 'year_emission DESC')
  end
  
  # List with user for administration purposes
  def list
    @users = User.find(:all)
  end
  def show
    @user = User.find(params[:id])
  end
  
  # Main page for user profile
  def profile
    @user = User.find(session[:id])
    
    # Calculate total CO2
    dopplremissions = @user.dopplr_emissions.find(:all)
    
    @total = 0 
    @year = 0
    @month = 0
    month2 = 0
    month3 = 0
    month4 = 0
    month5 = 0
    month6 = 0
    @plane = 0
    @train = 0
    @car = 0
    @bus = 0
    
    for emission in dopplremissions
      @total += emission.co2
      if emission.date.year == Time.now.year then @year += emission.co2 end
      if (emission.date.month == Time.now.month &&  emission.date.year == Time.now.year)then @month += emission.co2 end
      if (emission.date.month == Time.now.month-1 &&  emission.date.year == Time.now.year)then month2 += emission.co2 end
      if (emission.date.month == Time.now.month-2 &&  emission.date.year == Time.now.year)then month3 += emission.co2 end
      if (emission.date.month == Time.now.month-3 &&  emission.date.year == Time.now.year)then month4 += emission.co2 end
      if (emission.date.month == Time.now.month-4 &&  emission.date.year == Time.now.year)then month5 += emission.co2 end
      if (emission.date.month == Time.now.month-5 &&  emission.date.year == Time.now.year)then month6 += emission.co2 end
      case emission.source.id
      when 3..4 
       @plane += emission.co2
     when 5
       @train += emission.co2
     when 7..13
       @car += emission.co2
     when 15
       @bus+= emission.co2
     when 6
       @bus+= emission.co2
     when 14
       @train += emission.co2
       end
    end
    
    @grafico="http://chart.apis.google.com/chart?chs=250x150&amp;cht=bvg&amp;chd=t:"+@year.round.to_s+","+@month.round.to_s+"|5600,460&chds=0,10000,0,10000&amp;chco=4D89F9,C6D9FD"
    
    @history="http://chart.apis.google.com/chart?chs=450x200&amp;cht=bvg&amp;chd=t:"+month6.to_s+","+month5.to_s+","+month4.to_s+","+month3.to_s+","+month2.to_s+","+@month.to_s+"&chds=0,5000&amp;chm=N,000000,0,-1,11&amp;chco=4D89F9"
    
    
    
    words = @user.name.split()
    firstname = words[0]
    
    case @year
      when 0..1499
        @text = "Hi "+ firstname + ",you're doing great."
      when 1500..1999
        @text = "Hi "+ firstname + ", you're reaching the limit this year"
      when 2000..3999
        @text = "Hi "+ firstname + ", you should reduce your emissions"
      else
        @text = firstname + ", you're a climate disaster..."
       end
  end
  
  
  # Main page for user profile
  def carbonto
    @user = User.find(session[:id])
    
    # Calculate total CO2
    dopplremissions = @user.dopplr_emissions.find(:all)
    
    @total = 0 
    @year = 0
    @month = 0

    
    for emission in dopplremissions
      @total += emission.co2
      if emission.date.year == Time.now.year then @year += emission.co2 end
      if (emission.date.month == Time.now.month &&  emission.date.year == Time.now.year)then @month += emission.co2 end
    end
    
  
    beer = Net::HTTP.get(URI.parse("http://carbon.to/beers.json?co2="+@year.round.to_s))
    
    beer = ActiveSupport::JSON.decode(beer)
    
    @beeramount = beer["conversion"]["amount"]
    
    laptop = Net::HTTP.get(URI.parse("http://carbon.to/laptop.json?co2="+@year.round.to_s))
    
    laptop = ActiveSupport::JSON.decode(laptop)
    
    @laptopamount = laptop["conversion"]["amount"]
    
  
  end
  
  # Detailed emissions
  def emissions
    @user = User.find(session[:id])
    
    # Take dopplremissions
    @peiremissions = @user.peir_emissions.find(:all, :order => "date DESC")
    @dopplremissions = @user.dopplr_emissions.find(:all, :order => "date DESC")
    @groups = @user.groups
    
  end
  
  def configuration
  @user = User.find(session[:id])
  end
  
  # Password management
  def changepassword
        flash[:notice] = ""
        @user = User.find(session[:id])
        if request.post? and @user.update_attributes(params[:user])
            redirect_to(:action => 'account')
        end
  end
  def resetpassword
        flash[:notice] = ""
        @user = User.find(params[:id])
        if request.post? and @user.update_attributes(params[:user])
            redirect_to :action => 'adminpasswords'
        end
  end
  
  
  # Update the emission year field for users
  def update_year_emissions
    User.find(:all).each do |user|
        total = 0
        user.dopplr_emissions.each do |d|
          if d.date.year == Time.now.year then total += d.co2 end
        end
        user.year_emission = total
        user.save
    end
  end
  
  # Dummy profile for showing as example
  # Main page for user profile
  def profile_example
    @user = User.find(5)
    
    # Calculate total CO2
    dopplremissions = @user.dopplr_emissions.find(:all)
    
    @total = 0 
    @year = 0
    @month = 0
    month2 = 0
    month3 = 0
    month4 = 0
    month5 = 0
    month6 = 0
    @plane = 0
    @train = 0
    @car = 0
    @bus = 0
    
    for emission in dopplremissions
      @total += emission.co2
      if emission.date.year == Time.now.year then @year += emission.co2 end
      if (emission.date.month == Time.now.month &&  emission.date.year == Time.now.year)then @month += emission.co2 end
      if (emission.date.month == Time.now.month-1 &&  emission.date.year == Time.now.year)then month2 += emission.co2 end
      if (emission.date.month == Time.now.month-2 &&  emission.date.year == Time.now.year)then month3 += emission.co2 end
      if (emission.date.month == Time.now.month-3 &&  emission.date.year == Time.now.year)then month4 += emission.co2 end
      if (emission.date.month == Time.now.month-4 &&  emission.date.year == Time.now.year)then month5 += emission.co2 end
      if (emission.date.month == Time.now.month-5 &&  emission.date.year == Time.now.year)then month6 += emission.co2 end
      case emission.source.id
      when 3..4 
       @plane += emission.co2
     when 5
       @train += emission.co2
     when 7..13
       @car += emission.co2
     when 15
       @bus+= emission.co2
     when 6
       @bus+= emission.co2
     when 14
       @train += emission.co2
       end
    end
    
    @grafico="http://chart.apis.google.com/chart?chs=250x150&amp;cht=bvg&amp;chd=t:"+@year.round.to_s+","+@month.round.to_s+"|5600,460&chds=0,10000,0,10000&amp;chco=4D89F9,C6D9FD"
    
    @history="http://chart.apis.google.com/chart?chs=450x200&amp;cht=bvg&amp;chd=t:"+month6.to_s+","+month5.to_s+","+month4.to_s+","+month3.to_s+","+month2.to_s+","+@month.to_s+"&chds=0,5000&amp;chm=N,000000,0,-1,11&amp;chco=4D89F9"
    
    
    
    words = @user.name.split()
    firstname = words[0]
    
    case @year
      when 0..1499
        @text = "Hi "+ firstname + ",you're doing great."
      when 1500..1999
        @text = "Hi "+ firstname + ", you're reaching the limit this year"
      when 2000..3999
        @text = "Hi "+ firstname + ", you should reduce your emissions"
      else
        @text = firstname + ", you're a climate disaster..."
       end
  end
  # Detailed emissions for dummy profile
  def emissions_example
    @user = User.find(5)
    
    # Take dopplremissions
    @peiremissions = @user.peir_emissions.find(:all, :order => "date DESC")
    @dopplremissions = @user.dopplr_emissions.find(:all, :order => "date DESC")
    @groups = @user.groups
    
  end
  
  

end