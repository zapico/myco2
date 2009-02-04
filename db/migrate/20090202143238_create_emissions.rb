class CreateEmissions < ActiveRecord::Migration
  def self.up
    create_table :emissions do |t|
      t.integer :user_id
      t.integer :source_id
      t.decimal :amount
      t.text :metadata
      t.date :start
      t.date :end
      t.timestamps
    end
  end

  def self.down
    drop_table :emissions
  end
end
