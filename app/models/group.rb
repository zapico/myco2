class Group < ActiveRecord::Base
has_and_belongs_to_many :users
has_many :goals
has_many :dopplr_emissions, :through => :users

end
