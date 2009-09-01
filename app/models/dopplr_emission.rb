class DopplrEmission < ActiveRecord::Base
  belongs_to :user
  belongs_to :source
  has_and_belongs_to_many :groups
end
