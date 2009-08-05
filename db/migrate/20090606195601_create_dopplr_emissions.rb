class CreateDopplrEmissions < ActiveRecord::Migration
  def self.up
    create_table :dopplr_emissions do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :dopplr_emissions
  end
end
