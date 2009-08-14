# Controller for retrieving information from PEIR
#
# Jorge L. Zapico 
# KTH, Centre for Sustainable Communications, 2009
# www.persuasiveservices.org

class PeirController < ApplicationController
  require 'xml'
  
  # Grabs the data from PEIR in a XML and writes in the db for peir_emissions
  def show
    
    # Starting variables 
	  @trips = ""
	  @data = 0;
	  @nrtrips = 0;
      
    #Get and parse XML
    parser = XML::Parser.file('https://peir.cens.ucla.edu/protected/private/stockholm_xml.php')
    doc = parser.parse
      doc.find('/trip').each do |p|
        # Process information
        id = p.attributes["id"]
        datapoints = p.attributes["dataCount"]

        # Aggregate information for return
  			@nrtrips ++
  			@data += datapoints
  			@trips += " " + id
        

      end
  end
  
  # Grabs the data from PEIR in a XML and writes in the db for peir_emissions
  def getdata
      
	  
	  # Getting the XML with all the trips and iterating by trip

	
		# Check if that trip already exist 

		
		# Create a new emission
		emission = PeirEmission.new
		
		# Add trip id
		emission.trip = trip['id']
		
		# Add user id
		emission.user_id = 2
		
	 	
	  	
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

	  redirect_to :controller => user, action => "profile"
	  
  #finish getdata    
  end
  


end