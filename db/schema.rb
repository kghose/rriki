# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20090330011916) do

  create_table "entries", :force => true do |t|
    t.string   "title"
    t.datetime "date"
    t.text     "body"
    t.string   "place"
    t.decimal  "lat"
    t.decimal  "lon"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "entries_tags", :id => false, :force => true do |t|
    t.integer "entry_id"
    t.integer "tag_id"
  end

  create_table "keywords", :force => true do |t|
    t.string   "name"
    t.string   "path_text"
    t.integer  "keyword_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "keywords_notes", :id => false, :force => true do |t|
    t.integer "keyword_id"
    t.integer "note_id"
  end

  create_table "keywords_sources", :id => false, :force => true do |t|
    t.integer "keyword_id"
    t.integer "source_id"
  end

  create_table "notes", :force => true do |t|
    t.string   "title"
    t.datetime "date"
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "rriki_params", :force => true do |t|
    t.string   "key"
    t.text     "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sources", :force => true do |t|
    t.text     "abstract"
    t.string   "address"
    t.string   "author"
    t.string   "booktitle"
    t.string   "chapter"
    t.string   "citekey"
    t.string   "edition"
    t.string   "editor"
    t.string   "filing_index"
    t.string   "howpublished"
    t.string   "institution"
    t.string   "journal"
    t.string   "month"
    t.string   "number"
    t.string   "organization"
    t.string   "pages"
    t.string   "publisher"
    t.string   "school"
    t.string   "series"
    t.string   "title"
    t.string   "source_type"
    t.string   "url"
    t.string   "volume"
    t.integer  "year"
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tags", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
