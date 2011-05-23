namespace :data do
  desc "Load data from the older version of RRiki and save it to the current database"
  "Call as rake data:migrate OLDDB=db/old_rriki.sqlite3"
  task :migrate => :environment do
    init
    # The hashes map the old id to the new id for each item
    noteidhash = firstpass_notes
    sourceidhash = firstpass_sources
    diaryidhash = firstpass_diary
    second_pass(noteidhash, sourceidhash)
    second_pass_diary(diaryidhash)
  end
end

# Anything we have to do first. Currently, just make a root keyword
def init
  root_key = Keyword.new(:name => 'rriki imported')
  root_key.save
end

# First pass, create the notes and copy all info
# Build up a hash mapping the old note to the new one
def firstpass_notes
  note_count = 0
  oldid_newid = {}
  OldDatabase::Note.find(:all, :order => :id).each do |old_note|
    new_note = Note.new()
    new_note.title = old_note.title
    new_note.date = old_note.note_date
    new_note.body = old_note.note_text
    new_note.save
    #puts new_note.title
    oldid_newid[old_note.id] = new_note.id
    note_count += 1
  end
  print "Found #{note_count} notes\n"
  return oldid_newid
end

# First pass, create the sources and copy all info.
# Build up a hash mapping the old note to the new one
def firstpass_sources
  source_count = 0
  oldid_newid = {}
  old_columns = OldDatabase::Source.column_names
  new_columns = Source.column_names
  print 'Importing sources, skipping columns: '
  old_columns.each do |column|
    if !new_columns.include? column
      print column + ", "
    end    
  end
  print "\n"
  OldDatabase::Source.find(:all, :order => :id).each do |old_source|
    new_source = Source.new()
    old_source.old_author_string_to_new
    old_columns.each do |column|
      if new_columns.include? column
        new_source[column] = old_source[column]
      end
      if column == 'note_text'
        new_source.body = old_source.note_text
      end
    end
    new_source.generate_citekey
    new_source.save
    oldid_newid[old_source.id] = new_source.id
    source_count += 1
  end
  print "Found #{source_count} sources\n"  
  return oldid_newid
end

# Convert the links to new form (and correct for shifted database ids)
# Treat keywords as separate notes and link each note to the keyword
def second_pass(noteidhash, sourceidhash)
  root_key = Keyword.find_by_name('rriki imported')
  Note.find(:all).each do |note|
    process(note, noteidhash, sourceidhash, root_key)
  end
  Source.find(:all).each do |source|
    process(source, noteidhash, sourceidhash, root_key)
  end
end

def process(item, noteidhash, sourceidhash, root_key)
  if item.body == nil
    item.body = ""
  else
    item.body = convert_links(item.body, noteidhash, sourceidhash)
    item.body = deal_with_keywords(item, root_key)
  end
  item.save
end

# Pass the body of a (new version) note or source that has the old style link
# mark up pointing to the item ids of the old database, along with the idhashes 
# that tell us which old note/source maps onto which new note/source
# Then convert the old style links into new style links
def convert_links(text, noteidhash, sourceidhash)
  txt = text.gsub(/\[([^\[]*)\]\[note(\d+?)\]/) { note_link($1, $2, noteidhash)}
  txt.gsub(/\[([^\[]*)\]\[source(\d+?)\]/) { source_link($1, $2, sourceidhash)}
end

def note_link(txt, id, noteidhash)
  nid = noteidhash[id.to_i]
  if nid == nil
    "#{txt} (no note with old id #{id})"
  else
    "[#{txt}][note:#{nid}]"
  end
end

def source_link(txt, id, sourceidhash)
  sid = sourceidhash[id.to_i]
  if sid == nil
    "#{txt} (no source with old id #{id})"    
  else
    source = Source.find(id.to_i)
    "#{txt} [source:#{source.citekey}]"  
  end
end

# Find what keywords are present, create a note with that title (if needed) and 
# add this note/source to that note
def deal_with_keywords(item, root_key)
  text = item.body
  text.gsub(/\[([^\[]*)\]\[keyword:(.*?)\]/) {keyword_link($1, $2, item, root_key)}
end

def keyword_link(txt, keyword, item, root_key)
  if keyword != nil
    key = Keyword.find_or_initialize_by_name(keyword.gsub('_',' '))
    item.keywords << key unless item.keywords.include? key
    root_key.keywords << key unless root_key.keywords.include? key
  end
  return txt
end

# Find all the diary entries and save them as notes (with note_type 'Diary Entry')
# 
def firstpass_diary
  entry_count = 0
  oldid_newid = {}
  OldDatabase::Entry.find(:all, :order => :id).each do |old_entry|
    new_entry = Entry.new()
    new_entry.title = old_entry.title
    old_entry.entry_date != nil ? new_entry.date = old_entry.entry_date : new_entry.date = Time.now
    new_entry.body = old_entry.entry_text
    new_entry.place = old_entry.place_name
    new_entry.lat = old_entry.place_lat
    new_entry.lon = old_entry.place_long
    new_entry.save
    oldid_newid[old_entry.id] = new_entry.id
    entry_count += 1
  end
  print "Found #{entry_count} diary entries\n"
  return oldid_newid  
end

def second_pass_diary(diaryidhash)
  Entry.find(:all).each do |entry|
    process_diary(entry, diaryidhash)
  end
end

def process_diary(entry, diaryidhash)
  if entry.body == nil
    entry.body = ""
  else
    entry.body = convert_diary_links(entry.body, diaryidhash)
    entry.body = deal_with_tags(entry)
  end
  entry.save
end

def convert_diary_links(text, diaryidhash)
  text.gsub(/\[([^\[]*)\]\[entry(\d+?)\]/) { entry_link($1, $2, diaryidhash)}
end

def entry_link(txt, id, diaryidhash)
  nid = diaryidhash[id.to_i]
  if nid == nil
    "#{txt} (no entry with old id #{id})"
  else
    "[#{txt}][entry:#{nid}]"
  end
end

# The tags are now moved out of the text body and are linked solely through the
# join table
def deal_with_tags(entry)
  text = entry.body
  text.gsub(/\[([^\[]*)\]\[tag:(.*?)\]/) {tag_link($1, $2, entry)}
end

def tag_link(txt, tag, entry)
  if tag != nil
    tag = Tag.find_or_initialize_by_name(tag.gsub('_',' '))
    entry.tags << tag unless entry.tags.include? tag
  end
  return txt
end

# ------------------------------- MODELS ---------------------------------------

require 'rubygems'
require 'active_record'

class External < ActiveRecord::Base
  self.abstract_class = true
  establish_connection(  
   :adapter  => 'sqlite3',   
   :database => ENV["OLDDB"])
end

module OldDatabase
  # We are ignoring relational tables because we have designed things so that
  # we can recreate relations from the text in the note body
  class Note < External  
  end

  class Source < External
    
    # Convert the old author string to the new form (Last Name, First Name MI)    
    def old_author_string_to_new
      original_author_string = self.author
      self.author = ""
      original_author_string.split("and").each do |name|
        name_fragments = name.strip.split(' ')   
        self.author += "#{name_fragments.pop}, "
        name_fragments.reverse!
        self.author += "#{name_fragments.pop} " while name_fragments.length > 0
        self.author += "\n"
      end
    end
    
  end
  
  class Entry < External  
  end
  
end