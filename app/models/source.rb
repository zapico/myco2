class Source < ActiveRecord::Base
  belongs_to :city
  has_many :emissions
end
