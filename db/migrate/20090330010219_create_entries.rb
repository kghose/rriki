class CreateEntries < ActiveRecord::Migration
  def self.up
    create_table :entries do |t|
      t.string :title
      t.datetime :date
      t.text :body
      t.string :place
      t.decimal :lat
      t.decimal :lon

      t.timestamps
    end
    
  end

  def self.down
    drop_table :entries
  end
end
