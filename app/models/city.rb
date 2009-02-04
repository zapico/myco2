class City < ActiveRecord::Base
  has_many :users
  has_many :sources
end
