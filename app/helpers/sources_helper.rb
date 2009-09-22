module SourcesHelper
  # Gives back the total per source, for instance total CO2 in flying this year
  def total(source_id)
    total = 0
    source = Source(source_id)
    dopplr = source.dopplr_emissions.find(:all, :conditions["date.to_date.month = ?",Time.now.month ]) 
    commuting = source.peir_emissions.find(:all, :conditions["date.to_date.month = ?",Time.now.month ]) 
    emmisions = source.emissions.find(:all, :conditions["date.to_date.month = ?",Time.now.month ]) 
    dopplr.each do |d|
      total += d.co2
    end
    commuting.each do |c|
      total += c.co2
    end
    emmisions.each do |e|
      total += e.co2
    end
    total
  end
  
  #Gives the total amount of emissions in the system
  def total_all
    total = 0
    dopplr = DopplrEmission.find(:all, :conditions["date.to_date.month = ?",Time.now.month ]) 
    commuting = PeirEmission.find(:all, :conditions["date.to_date.month = ?",Time.now.month ]) 
    emmisions = Emission.find(:all, :conditions["date.to_date.month = ?",Time.now.month ]) 
    dopplr.each do |d|
      total += d.co2
    end
    commuting.each do |c|
      total += c.co2
    end
    emmisions.each do |e|
      total += e.co2
    end
    total
  end
  
end
