class CreateEmissions < ActiveRecord::Migration
  def self.up
    create_table :emissions do |t|
      t.integer :user_id
      t.integer :source_id
      t.column :amount, :decimal, { :precision => 10, :scale => 9 }
      t.text :metadata
      t.datetime :start
      t.datetime :end
      t.timestamps
    end
  end

  def self.down
    drop_table :emissions
  end
end
