class CreateRrikiParam < ActiveRecord::Migration
  def self.up
    create_table :rriki_params do |t|
      t.string :key
      t.text :value

      t.timestamps
    end
  end

  def self.down
    drop_table :rriki_params
  end
end
