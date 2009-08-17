# Controller for retrieving information from Dopplr API
#
# Jorge L. Zapico 
# KTH, Centre for Sustainable Communications, 2009
# www.persuasiveservices.org

class DopplrController < ApplicationController

  # Link Dopplr Account to OurCO2 using API
  def link
    url ="http://localhost:3000/dopplr/"
    redirect_to "https://www.dopplr.com/api/AuthSubRequest?scope=http://www.dopplr.com&next="+url+"&session=1"
  end
  
  def index 
    # Save the token in the user
    if (params[:token]) then
       
       d = Dopplr.new
       d.set_token(params[:token])

      
       @user = User.find(session[:id])
       @user.tokendopplr = params[:token].to_s
       @user.update_attributes(params[:user])
       @token = params[:token].to_s
   
    end
  end
  
  # Grabs the data from Dopplr and writes in the db for dopplr_emissions
  def getdata
    
    user = User.find(session[:id])
      
    # Connecting with dopplr and creating session    
    d = Dopplr.new
    d.set_token(user.tokendopplr)
    session = d.upgrade_to_session
    d.set_token(session)
	  
	  # Getting the XML with all the trips and iterating by trip
	  d.trips_info['trip'].each do |trip|
		
		
		# Check if that trip already exist 
		if DopplrEmission.find(:first, :conditions => ["trip = ?", trip['id'] ]) == nil then
		
		# Create a new emission
		emission = DopplrEmission.new
		# Add trip id
		emission.trip = trip['id']
		# Add user id
		emission.user_id = user.id
		
		
		# Get the coordinates of the startpoint based on the position of the day before traveling
		startdate = trip['start']
		emission.date = startdate.to_date
		
		startplace = d.location_on_date(:date => startdate.to_time - 1.day)['location']
		if startplace.has_key?('trip')
			lat = startplace['trip']['city']['latitude']
			long = startplace['trip']['city']['longitude']
			namestart = startplace['trip']['city']['name']
		else
			lat = startplace['home']['latitude']
			long = startplace['home']['longitude']
			namestart = startplace['home']['name']
		end
		
		# Calculate the distance in km based in Km based on the latitude and longitude
		dLat = 3.141592653589793238462643383298 * (trip['city']['latitude'] - lat) / 180
        
        dLon = 3.141592653589793238462643383298 *(trip['city']['longitude'] - long) / 180
		
		a = Math.sin(dLat/2) * Math.sin(dLat/2) + Math.cos( 3.141592653589793238462643383298 * lat / 180) * Math.cos(3.141592653589793238462643383298 * trip['city']['latitude']/ 180) * Math.sin(dLon/2) * Math.sin(dLon/2)
	  	
	  	c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a))
	  	distancekm = 6371 * c
	  	
	  	#Add emission km
	  	emission.km = distancekm
	  	
	  	# Calculate co2 if flight
	  	if trip['outgoing_transport_type'] == 'plane' then
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
	  	if trip['outgoing_transport_type'] == 'train' then
	  		co2 = distancekm * Source.find(5).factor
	  		emission.co2 = co2
	  	   	emission.source = Source.find(5)
	  		
	  	end
	  	
	  	# Calculate co2 if bus
		if trip['outgoing_transport_type'] == 'bus' then
	  		co2 = distancekm * Source.find(6).factor
	  		emission.co2 = co2
	  	 	emission.source = Source.find(6)
	  	end  	
	  	
	  	# Calculate co2 if car
	  	if trip['outgoing_transport_type'] == 'car' then
	  		co2 = distancekm * Source.find(7).factor
	  		emission.co2 = co2
	  	   	emission.source = Source.find(7)
	  	end  	
	  	
	  emission.save

	  	
	  	# Calculate return
	  	
	  	finishdate = trip['finish']
		finishplace = d.location_on_date(:date => finishdate.to_time + 1.day)['location']
		
		if finishplace.has_key?('trip')
			# The trip continues to another place, so nothing happens
			namestart = ""
		else
			
			# Create a new emission
		    returnemission = DopplrEmission.new
			# Add trip id
			returnemission.trip = trip['id']
			# Add user id
			returnemission.user_id = 2
			returnemission.date = finishdate.to_date
			
			# The trip returns home	
			
			lat = trip['city']['latitude']
			long = trip['city']['longitude']
			namestart = trip['city']['name']
			
			
			# ReCalculate the distance in km based in Km based on the latitude and longitude
			dLat = 3.141592653589793238462643383298 * (startplace['home']['latitude'] - lat) / 180
        
        	dLon = 3.141592653589793238462643383298 * (startplace['home']['longitude'] - long) / 180
		
			a = Math.sin(dLat/2) * Math.sin(dLat/2) + Math.cos( 3.141592653589793238462643383298 * lat / 180) * Math.cos(3.141592653589793238462643383298 * startplace['home']['latitude']/ 180) * Math.sin(dLon/2) * Math.sin(dLon/2)
	  	
	  		c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a))
	  		distancekm = 6371 * c
	  		returnemission.km =distancekm
			
			# Recalculate co2
			# Calculate co2 if flight
	  		if trip['return_transport_type'] == 'plane' then
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
	  		if trip['return_transport_type'] == 'train' then
	  			co2 = distancekm * Source.find(5).factor
	  			returnemission.co2 = co2
	  	   		returnemission.source = Source.find(5)
	  		end
	  	
	  		# Calculate co2 if bus
			if trip['return_transport_type'] == 'bus' then
	  			co2 = distancekm * Source.find(6).factor
	  			returnemission.co2 = co2
	  	   		returnemission.source = Source.find(6)
	  		end  	
		  	
		  	# Calculate co2 if car
		  	if trip['return_transport_type'] == 'car' then
	  			co2 = distancekm * Source.find(7).factor
	  			returnemission.co2 = co2
	  	   		returnemission.source = Source.find(7)
		  	end  
		returnemission.save
        	
		end
	  #finish if	
	  end	  
	  #finish each
	  end
	  redirect_to :controller => user, :action => "profile"
	  
  #finish getdata    
  end
  
  # Index shows the details but it doesn't save the trips in the database.
  def index_old
      
      # Connecting with dopplr and creating session
      d = Dopplr.new
      puts d.login_url("http://localhost:3000/dopplr/")
      d.set_token('b67fa9cd35c665e6fd20ed32533b4bae')
      session = d.upgrade_to_session
      d.set_token(session)
	  
	  # Starting variables
	  @trips = "" 
	  @km = 0;
	  @nrtrips = 0;
	  @totalco2 = 0;
	  
	  # Getting the XML with all the trips and iterating by trip
	  d.trips_info['trip'].each do |trip|
		
		# Get the coordinates of the startpoint based on the position of the day before traveling
		startdate = trip['start']
		startplace = d.location_on_date(:date => startdate.to_time - 1.day)['location']
		if startplace.has_key?('trip')
			lat = startplace['trip']['city']['latitude']
			long = startplace['trip']['city']['longitude']
			namestart = startplace['trip']['city']['name']
		else
			lat = startplace['home']['latitude']
			long = startplace['home']['longitude']
			namestart = startplace['home']['name']
		end
		
		# Calculate the distance in km based in Km based on the latitude and longitude
		dLat = 3.141592653589793238462643383298 * (trip['city']['latitude'] - lat) / 180
        
        dLon = 3.141592653589793238462643383298 *(trip['city']['longitude'] - long) / 180
		
		a = Math.sin(dLat/2) * Math.sin(dLat/2) + Math.cos( 3.141592653589793238462643383298 * lat / 180) * Math.cos(3.141592653589793238462643383298 * trip['city']['latitude']/ 180) * Math.sin(dLon/2) * Math.sin(dLon/2)
	  	
	  	c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a))
	  	distancekm = 6371 * c
	  	
	  	# Calculate co2 if flight
	  	if trip['outgoing_transport_type'] == 'plane' then
	  		if distancekm < 800 then
	  	   	 	# If short haul
	  	   		co2 = distancekm * Source.find(3).factor
	  		else
	  	   		# If long haul
	  	   		co2 = distancekm * Source.find(4).factor
	  		end
	  	end
	  	
	  	# Calculate co2 if train
	  	if trip['outgoing_transport_type'] == 'train' then
	  		co2 = distancekm * Source.find(5).factor
	  	end
	  	
	  	# Calculate co2 if bus
		if trip['outgoing_transport_type'] == 'bus' then
	  		co2 = distancekm * Source.find(6).factor
	  	end  	
	  	
	  	# Calculate co2 if car
	  	if trip['outgoing_transport_type'] == 'car' then
	  		co2 = distancekm * Source.find(7).factor
	  	end  	
	  	
	  	# Aggregate information
	  	@nrtrips += 1
	  	@totalco2 += co2 
	  	@km += distancekm
	  	@trips = @trips + " From " + namestart + " to " + trip['city']['name'] + " was "+ distancekm.round.to_s + " Km. By: " + trip['outgoing_transport_type'] + " and emitted "+ co2.round.to_s + " Kg CO2. <br>"
	  	
	  	# Calculate return
	  	
	  	finishdate = trip['finish']
		finishplace = d.location_on_date(:date => finishdate.to_time + 1.day)['location']
		
		if finishplace.has_key?('trip')
			# The trip continues to another place, so nothing happens
			namestart = ""
		else
			# The trip returns home	
			
			lat = trip['city']['latitude']
			long = trip['city']['longitude']
			namestart = trip['city']['name']
			
			
			# ReCalculate the distance in km based in Km based on the latitude and longitude
			dLat = 3.141592653589793238462643383298 * (startplace['home']['latitude'] - lat) / 180
        
        	dLon = 3.141592653589793238462643383298 * (startplace['home']['longitude'] - long) / 180
		
			a = Math.sin(dLat/2) * Math.sin(dLat/2) + Math.cos( 3.141592653589793238462643383298 * lat / 180) * Math.cos(3.141592653589793238462643383298 * startplace['home']['latitude']/ 180) * Math.sin(dLon/2) * Math.sin(dLon/2)
	  	
	  		c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a))
	  		distancekm = 6371 * c
			
			# Recalculate co2
			# Calculate co2 if flight
	  		if trip['return_transport_type'] == 'plane' then
	  			if distancekm < 800 then
	  	   	 		# If short haul
	  	   			co2 = distancekm * Source.find(3).factor
	  			else
	  	   			# If long haul
	  	   			co2 = distancekm * Source.find(4).factor
	  			end
	  		end
	  	
	  		# Calculate co2 if train
	  		if trip['return_transport_type'] == 'train' then
	  			co2 = distancekm * Source.find(5).factor
	  		end
	  	
	  		# Calculate co2 if bus
			if trip['return_transport_type'] == 'bus' then
	  			co2 = distancekm * Source.find(6).factor
	  		end  	
		  	
		  	# Calculate co2 if car
		  	if trip['return_transport_type'] == 'car' then
	  			co2 = distancekm * Source.find(7).factor
		  	end  
	
			# Aggregate information for return
			@km += distancekm
			@totalco2 += co2
			@trips = @trips + " From " + namestart + " to " + startplace['home']['name'] + " was "+ distancekm.round.to_s + " Km. By: " + trip['return_transport_type'] + " and emitted "+ co2.round.to_s + " Kg CO2. <br><br><br>"

		end
	  	
	  end	  
	 
      
  end
  
end