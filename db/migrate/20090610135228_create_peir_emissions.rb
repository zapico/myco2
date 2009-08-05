class CreatePeirEmissions < ActiveRecord::Migration
  def self.up
    create_table :peir_emissions do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :peir_emissions
  end
end
