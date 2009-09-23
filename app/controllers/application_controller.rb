# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
require 'digest/sha1'

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  
  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => '800f03510a8cc5a2142335086094cc7b'
  
  def authorize  
     unless session[:id] && User.find_by_id(session[:id])
          flash[:notice] = "Please log in"
          redirect_to(:controller => "users", :action => "login")
     end
  end
  
  def authorize_admin
     unless session[:id] && User.find_by_id(session[:id]).id == 5
          flash[:notice] = "Please log in"
          redirect_to(:controller => "users", :action => "profile")
     end
  end
  
  protected
  
  def http_basic_authentication
        authenticate_or_request_with_http_basic do |email , password|    
        user = User.find(:first, :conditions => ['email = ?' , email])
        if user
            string_to_hash = password + user.password_salt
            expected_password = Digest::SHA1.hexdigest(string_to_hash)
            if user.password_hash != expected_password
                user = nil
            end
                
        end
        user
      end
  end
  
  # See ActionController::Base for details 
  # Uncomment this to filter the contents of submitted sensitive data parameters
  # from your application log (in this case, all fields with names like "password"). 
  # filter_parameter_logging :password
end
