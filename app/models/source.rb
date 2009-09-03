class Source < ActiveRecord::Base
  belongs_to :city
  has_many :emissions
  has_many :dopplr_emissions
  has_many :peir_emissions
end
