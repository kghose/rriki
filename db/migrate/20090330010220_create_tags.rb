class CreateTags < ActiveRecord::Migration
  def self.up
    create_table :tags do |t|
      t.string :name
      t.timestamps
    end

    create_table :entries_tags, :id => false do |t|
      t.references :entry, :tag
    end
    
  end

  def self.down
    drop_table :tags
    drop_table :entries_tags
  end
end
