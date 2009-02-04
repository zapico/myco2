class CreateEmissions < ActiveRecord::Migration
  def self.up
    create_table :emissions do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :emissions
  end
end
