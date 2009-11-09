# Controller for retrieving information from Dopplr API
#
# Jorge L. Zapico 
# KTH, Centre for Sustainable Communications, 2009
# www.persuasiveservices.org

class DopplrController < ApplicationController
  before_filter :authorize, :only => [:link]
 
  require 'dopplr'
  
  # Link Dopplr Account to OurCO2 using API
  def link
    url ="http://ourco2.org/dopplr/"
    id = session[:id].to_s
    redirect_to "https://www.dopplr.com/api/AuthSubRequest?scope=http://www.dopplr.com&next="+url+"&session=1&userid="+id
  end
  
  # After linking the Dopplr account it saves the token and gives a confirmation to the user
  def index 
    # Save the token in the user
    if (params[:token]) then
       
       client = Dopplr::Client.new
       client.login_url "http://ourco2.org/dopplr/"
       client.token = params[:token]
       
       # Transform into a session
       @token = client.create_session
       
       # Saves it in the user
       @user = User.find(params[:userid])
       @user.tokendopplr = @token
       @user.save
              
    end
  end
  
  # Refresh the data from all users
  def refresh_all
    User.find(:all, :conditions => ["tokendopplr != NULL"]).each do |u|
      call :action => getdata, :id => user.id
    end
    render :nothing => true 
  end
    
  
  # Grabs the data from Dopplr and writes in the db for dopplr_emissions
  def getdata
    
    user = User.find(params[:id])
      
    # Connecting with dopplr and creating session    
    client = Dopplr::Client.new
    client.token = user.tokendopplr
	  
	  # Getting the XML with all the trips and iterating by trip
	  mike = client.traveller
	  mike.trips.each do |trip|
		
		# Create a new emission
		emission = DopplrEmission.new
		# Add trip id
		emission.trip = trip.id.to_s
		# Add user id
		emission.user_id = user.id
		emission.date = trip.start.to_date
		
		# Get the coordinates of the startpoint based on the position of the day before traveling
		startdate = trip.start.to_date - 1.day
		startplace = client.get('location_on_date', :date => startdate)['location']

		
		if startplace['trip'] != nil
			lat = startplace['trip']['city']['latitude']
			long = startplace['trip']['city']['longitude']
			namestart = startplace['trip']['city']['name']
			
		else
			lat = startplace['home']['latitude']
			long = startplace['home']['longitude']
			namestart = startplace['home']['name']
		end
		
		emission.from = namestart
		emission.to = trip.city.name
		
		# Calculate the distance in km based in Km based on the latitude and longitude
		dLat = 3.141592653589793238462643383298 * (trip.city.latitude - lat) / 180
        
        dLon = 3.141592653589793238462643383298 *(trip.city.longitude - long) / 180
		
		a = Math.sin(dLat/2) * Math.sin(dLat/2) + Math.cos( 3.141592653589793238462643383298 * lat / 180) * Math.cos(3.141592653589793238462643383298 * trip.city.latitude/ 180) * Math.sin(dLon/2) * Math.sin(dLon/2)
	  	
	  	c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a))
	  	distancekm = 6371 * c
	  	
	  	#Add emission km
	  	emission.km = distancekm
	  	
	  	# Calculate co2 if flight
	  	if trip.outgoing_transport == 'plane' then
	  		if distancekm < 800 then
	  	   	 	# If short haul
	  	   		co2 = distancekm * Source.find(3).factor
	  	   		emission.co2 = co2
	  	   		emission.source = Source.find(3)
	  		else
	  	   		# If long haul
	  	   		co2 = distancekm * Source.find(4).factor
	  	   		emission.co2 = co2
	  	   		emission.source = Source.find(4)
	  		end
	  	end
	  	
	  	# Calculate co2 if train
	  	if trip.outgoing_transport == 'train' then
	  		co2 = distancekm * Source.find(5).factor
	  		emission.co2 = co2
	  	   	emission.source = Source.find(5)
	  		
	  	end
	  	
	  	# Calculate co2 if bus
		if trip.outgoing_transport == 'bus' then
	  		co2 = distancekm * Source.find(6).factor
	  		emission.co2 = co2
	  	 	emission.source = Source.find(6)
	  	end  	
	  	
	  	# Calculate co2 if car
	  	if trip.outgoing_transport == 'car' then
	  		co2 = distancekm * Source.find(7).factor
	  		emission.co2 = co2
	  	   	emission.source = Source.find(7)
	  	end  	
	     # Check if that trip already exist 
    if DopplrEmission.find(:first, :conditions => {:date => emission.date, :from => emission.from }) == nil then	
	     emission.save
		end
	  	# Calculate return
		  # Check where the user is the day after
		  finishdate = trip.finish.to_date + 1.day
  		finishplace = client.get('location_on_date', :date => finishdate)['location']
		
      if finishplace.has_key?('trip')
  			# If the user is traveling then check if it's the same location as the departure city from the previous trip
  			if finishplace['trip']['city']['name'] == namestart
  		    # Return to same city as the start (but not the home place)
  		    lat = trip.city.latitude
    			long = trip.city.longitude
    			namestart = trip.city.name
    			latfinish = finishplace['trip']['city']['latitude']
    		  longfinish = finishplace['trip']['city']['longitude']
    		  namefinish = finishplace['trip']['city']['name']
  		  else
		      # If not the trip continues to another place, so we iterate again, no return trip yet
		      namestart = ""
		    end
	      else
  			# If the user is not traveling that day then the trip returns home	
  			latfinish = finishplace['home']['latitude']
  		  longfinish = finishplace['home']['longitude']
  		  namefinish = finishplace['home']['name']
		  end
		  
		  if namestart != ""
		    
		 
			lat = trip.city.latitude
			long = trip.city.longitude
			namestart = trip.city.name
			

			
			
			# Create a new emission
		    returnemission = DopplrEmission.new
			# Add trip id
			returnemission.trip = trip.id
			# Add user id
			returnemission.user_id = user.id
			returnemission.date = trip.finish.to_date
			
			# The trip returns home	
			
			lat = trip.city.latitude
			long = trip.city.longitude
			namestart = trip.city.name
			
			returnemission.from = namestart
  		returnemission.to = namefinish
			
			# ReCalculate the distance in km based in Km based on the latitude and longitude
			dLat = 3.141592653589793238462643383298 * (latfinish - lat) / 180
        
      dLon = 3.141592653589793238462643383298 * (longfinish - long) / 180
		
			a = Math.sin(dLat/2) * Math.sin(dLat/2) + Math.cos( 3.141592653589793238462643383298 * lat / 180) * Math.cos(3.141592653589793238462643383298 * latfinish/ 180) * Math.sin(dLon/2) * Math.sin(dLon/2)
	  	
	  	c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a))
	  	distancekm = 6371 * c
	  	returnemission.km =distancekm
			
			# Recalculate co2
			# Calculate co2 if flight
	  		if trip.return_transport == 'plane' then
	  			if distancekm < 800 then
	  	   	 		# If short haul
	  	   			co2 = distancekm * Source.find(3).factor
	  	   			returnemission.co2 = co2
	  	   			returnemission.source = Source.find(3)
	  	   			
	  			else
	  	   			# If long haul
	  	   			co2 = distancekm * Source.find(4).factor
	  	   			returnemission.co2 = co2
	  	   			returnemission.source = Source.find(4)
	  			end
	  		end
	  	
	  		# Calculate co2 if train
	  		if trip.return_transport == 'train' then
	  			co2 = distancekm * Source.find(5).factor
	  			returnemission.co2 = co2
	  	   		returnemission.source = Source.find(5)
	  		end
	  	
	  		# Calculate co2 if bus
			if trip.return_transport == 'bus' then
	  			co2 = distancekm * Source.find(6).factor
	  			returnemission.co2 = co2
	  	   		returnemission.source = Source.find(6)
	  		end  	
		  	
		  	# Calculate co2 if car
		  	if trip.return_transport == 'car' then
	  			co2 = distancekm * Source.find(7).factor
	  			returnemission.co2 = co2
	  	   		returnemission.source = Source.find(7)
		  	end  
		if DopplrEmission.find(:first, :conditions => {:date => returnemission.date, :from => returnemission.from }) == nil then
      returnemission.save
    end
		end
	  #finish each
	  end
	  redirect_to :controller => 'users', :action => "profile"
	  
  #finish getdata    
  end
  
  # index_old connected with index_old.rhtml
  # Index shows the details but it doesn't save the trips in the database.
  # Just for testing purposes
  # Jorge L. Zapico
  
  def index_old
      
    user = User.find(session[:id])
      
    # Connecting with dopplr and creating session    
    client = Dopplr::Client.new
    client.token = user.tokendopplr
	  
	  # Getting the XML with all the trips and iterating by trip
	  mike = client.traveller
	 
	  
	  # Starting variables
	  @trips = "" 
	  @km = 0;
	  @nrtrips = 0;
	  @totalco2 = 0;
	  
	  # Getting the XML with all the trips and iterating by trip
	  mike.trips.each do |trip|
		
		# Get the coordinates of the startpoint based on the position of the day before traveling
		startdate = trip.start.to_date - 1.day
		startplace = client.get('location_on_date', :date => startdate)['location']
		
		if startplace['trip'] != nil
			lat = startplace['trip']['city']['latitude']
			long = startplace['trip']['city']['longitude']
			namestart = startplace['trip']['city']['name']
		else
			lat = startplace['home']['latitude']
			long = startplace['home']['longitude']
			namestart = startplace['home']['name']
		end
		
		# Calculate the distance in km based in Km based on the latitude and longitude
		dLat = 3.141592653589793238462643383298 * (trip.city.latitude - lat) / 180
        
    dLon = 3.141592653589793238462643383298 *(trip.city.longitude - long) / 180
		
		a = Math.sin(dLat/2) * Math.sin(dLat/2) + Math.cos( 3.141592653589793238462643383298 * lat / 180) * Math.cos(3.141592653589793238462643383298 * trip.city.latitude/ 180) * Math.sin(dLon/2) * Math.sin(dLon/2)
	  	
	  	c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a))
	  	distancekm = 6371 * c
	  	
	  	# Calculate co2 if flight
	  	if trip.outgoing_transport == 'plane' then
	  		if distancekm < 800 then
	  	   	 	# If short haul
	  	   		co2 = distancekm * Source.find(3).factor
	  		else
	  	   		# If long haul
	  	   		co2 = distancekm * Source.find(4).factor
	  		end
	  	end
	  	
	  	# Calculate co2 if train
	  	if trip.outgoing_transport == 'train' then
	  		co2 = distancekm * Source.find(5).factor
	  	end
	  	
	  	# Calculate co2 if bus
		if trip.outgoing_transport. == 'bus' then
	  		co2 = distancekm * Source.find(6).factor
	  	end  	
	  	
	  	# Calculate co2 if car
	  	if trip.outgoing_transport == 'car' then
	  		co2 = distancekm * Source.find(7).factor
	  	end  	
	  	
	  	# Aggregate information
	  	@nrtrips += 1
	  	@totalco2 += co2 
	  	@km += distancekm
	  	@trips = @trips + " From " + namestart + " to " + trip.city.name + " was "+ distancekm.round.to_s + " Km. By: " + trip.outgoing_transport + " and emitted "+ co2.round.to_s + " Kg CO2. <br>"
	  	
	  	# Calculate return
		  
		  finishdate = trip.finish.to_date + 1.day
  		finishplace = client.get('location_on_date', :date => finishdate)['location']
		
      if finishplace.has_key?('trip')
  			
  			if finishplace['trip']['city']['name'] == namestart
  		    # Return to same city as the start (but not the home place)
  		    lat = trip.city.latitude
    			long = trip.city.longitude
    			namestart = trip.city.name
    			latfinish = finishplace['trip']['city']['latitude']
    		  longfinish = finishplace['trip']['city']['longitude']
    		  namefinish = finishplace['trip']['city']['name']
  		  else
		      # The trip continues to another place, so nothing happens
		      namestart = ""
		    end
	      else
  			# The trip returns home	
  			latfinish = finishplace['home']['latitude']
  		  longfinish = finishplace['home']['longitude']
  		  namefinish = finishplace['home']['name']
		  end
		  
		  if namestart != ""
		    
		
			lat = trip.city.latitude
			long = trip.city.longitude
			namestart = trip.city.name
		  

			
			# ReCalculate the distance in km based in Km based on the latitude and longitude
			dLat = 3.141592653589793238462643383298 * (latfinish- lat) / 180
        
        	dLon = 3.141592653589793238462643383298 * (longfinish - long) / 180
		
			a = Math.sin(dLat/2) * Math.sin(dLat/2) + Math.cos( 3.141592653589793238462643383298 * lat / 180) * Math.cos(3.141592653589793238462643383298 * latfinish/ 180) * Math.sin(dLon/2) * Math.sin(dLon/2)
	  	
	  		c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a))
	  		distancekm = 6371 * c
			
			# Recalculate co2
			# Calculate co2 if flight
	  		if trip.return_transport == 'plane' then
	  			if distancekm < 800 then
	  	   	 		# If short haul
	  	   			co2 = distancekm * Source.find(3).factor
	  			else
	  	   			# If long haul
	  	   			co2 = distancekm * Source.find(4).factor
	  			end
	  		end
	  	
	  		# Calculate co2 if train
	  		if trip.return_transport == 'train' then
	  			co2 = distancekm * Source.find(5).factor
	  		end
	  	
	  		# Calculate co2 if bus
			if trip.return_transport == 'bus' then
	  			co2 = distancekm * Source.find(6).factor
	  		end  	
		  	
		  	# Calculate co2 if car
		  	if trip.return_transport == 'car' then
	  			co2 = distancekm * Source.find(7).factor
		  	end  
	
			# Aggregate information for return
			@km += distancekm
			@totalco2 += co2
			@trips = @trips + " From " + namestart + " to " + namefinish + " was "+ distancekm.round.to_s + " Km. By: " + trip.return_transport + " and emitted "+ co2.round.to_s + " Kg CO2" + trip.id.to_s + "<br><br><br>"

		end
	  	
	  end	  
	 
      
  end
  
end