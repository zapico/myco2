class UsersController < ApplicationController
  before_filter :authorize, :only => [:edit, :destroy, :account, :changepassword, :profile]
  before_filter :login_required, :only => [:delete, :resetpassword, :adminpasswords]

  
  def login_required
    unless session[:id] && User.find(session[:id]).id == 2
      redirect_to(:controller => "users", :action => "login")
    end
  end
  
  
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
  
  def new
    @user = User.new(params[:user])
    if request.post? and @user.save
      flash[:notice] = 'User was successfully created.'
      redirect_to :action => 'login'
    else
      render :action => 'new'
    end
  end

  def edit
      flash[:notice] = ""
      @user = User.find(params[:id])
      @cities = City.find(:all)
      if request.post? and @user.update_attributes(params[:user])
              redirect_to :action => 'profile'
      end
  end
  
  def adminpasswords
end
  def index
  end
  def list
    @users = User.find(:all)
  end
  def show
    @user = User.find(params[:id])
  end
  def profile
    @user = User.find(session[:id])
        @emissions = @user.emissions.find(:all)
    @total = 0
    for emission in @emissions
      @total += emission.amount
    end
  end
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

end