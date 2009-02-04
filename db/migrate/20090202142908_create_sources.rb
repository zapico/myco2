class CreateSources < ActiveRecord::Migration
  def self.up
    create_table :sources do |t|
      t.integer :city_id
      t.string :name
      t.column :factor, :decimal, { :precision => 10, :scale => 9 }
      t.text :metadata
      t.timestamps
    end
  end

  def self.down
    drop_table :sources
  end
end
