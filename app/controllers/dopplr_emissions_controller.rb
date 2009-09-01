# Controller for storing information from Dopplr API
#
# Jorge L. Zapico 
# KTH, Centre for Sustainable Communications, 2009
# www.persuasiveservices.org

class DopplrEmissionsController < ApplicationController
  before_filter :authorize
  
def add_to_group
  emission = DopplrEmission.find(params[:id])
  group = Group.find(params[:group])
  emission.groups << group
  redirect_to :controller => "users", :action => "emissions" 
  
end

def remove_from_group
  emission = DopplrEmission.find(params[:id])
  group = Group.find(params[:group])
  emission.groups.delete(group)
  redirect_to :controller => "users", :action => "emissions" 
end

end
