class CreateKeywords < ActiveRecord::Migration
  def self.up
    create_table :keywords do |t|
      t.string :name
      t.string :path_text
      t.references :keyword
      t.timestamps
    end

    create_table :keywords_notes, :id => false do |t|
      t.references :keyword, :note
    end

    create_table :keywords_sources, :id => false do |t|
      t.references :keyword, :source
    end
  end

  def self.down
    drop_table :keywords
    drop_table :keywords_notes
    drop_table :keywords_sources    
  end
end
