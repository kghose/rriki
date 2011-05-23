class CreateSources < ActiveRecord::Migration
  def self.up
    create_table :sources do |t|
      t.text   :abstract
      t.string :address
      t.string :author
      t.string :booktitle
      t.string :chapter
      t.string :citekey
      t.string :edition
      t.string :editor
      t.string :filing_index
      t.string :howpublished
      t.string :institution
      t.string :journal
      t.string :month
      t.string :number
      t.string :organization
      t.string :pages
      t.string :publisher
      t.string :school
      t.string :series
      t.string :title
      t.string :source_type
      t.string :url
      t.string :volume
      t.integer :year

      t.text   :body
      
      t.timestamps
    end
  end

  def self.down
    drop_table :sources
  end
end
