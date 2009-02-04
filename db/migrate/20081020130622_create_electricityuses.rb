class CreateElectricityuses < ActiveRecord::Migration
  def self.up
    create_table :electricityuses do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :electricityuses
  end
end
