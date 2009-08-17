class CreatePeirs < ActiveRecord::Migration
  def self.up
    create_table :peirs do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :peirs
  end
end
