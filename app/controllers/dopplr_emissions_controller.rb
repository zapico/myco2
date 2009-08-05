# Controller for storing information from Dopplr API
#
# Jorge L. Zapico 
# KTH, Centre for Sustainable Communications, 2009
# www.persuasiveservices.org

class DopplrEmissionsController < ApplicationController

def changeuser
	for emission in DopplrEmissions.find(:all) do
		emission.user_id = 5
	    emission.update_attributes
	end
end

end
