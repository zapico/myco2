# API controller for getting the user aggregate CO2 information
#
# Jorge L. Zapico 
# KTH, Centre for Sustainable Communications, 2009
# www.persuasiveservices.org

class GetCo2Controller < ApplicationController
  before_filter :http_basic_authentication

    #Give back an XML with all the Dopplr trips
    #Provisional version
    def my_co2
      @user = User.find(session[:id])
      
      # Calculate total CO2
      @dopplremissions = @user.dopplr_emissions.find(:all)
      @total = 0 
      for emission in @dopplremissions
        @total += emission.co2
      end
      
      #Generate XML
      respond_to do |format|
        format.xml  { render :xml => @dopplremissions }
      end
      
    end

end
