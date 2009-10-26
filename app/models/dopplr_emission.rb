class DopplrEmission < ActiveRecord::Base
  belongs_to :user
  belongs_to :source
  has_many :groups, :through => :users
  
end
