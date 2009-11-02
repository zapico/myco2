module GroupsHelper
  def position (userid)
      user = User.find(userid)
      location = "home"
      if user.city then
        location = user.city.name
      end
      if user.tokendopplr then
      # Connecting with dopplr and creating session    
      client = Dopplr::Client.new
      client.token = user.tokendopplr

  	  # Getting the position today
      location = client.traveller.current_city.name
      end
     return location
  end
end
