module UsersHelper
  
  # Gives back the total CO2 emissions
  def total_co2(id)
    total = 0
    user = User.find(id)
    if user.tokendopplr then
      user.dopplr_emissions.each do |d|
        total += d.co2
      end
    end
    total
  end
  

  
end
