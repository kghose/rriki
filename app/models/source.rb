#    RRiki is a notes and citations management software
#    Copyright (C) 2009 - Kaushik Ghose - kghose@users.sourceforge.net
# 
#    This file is part of RRiki.
#
#    RRiki is free software; you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation; either version 3 of the License, or
#    (at your option) any later version.
#
#    RRiki is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with RRiki; if not, write to the Free Software
#    Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA

require 'pubmed_handler'

class Source < ActiveRecord::Base
  default_scope :order => 'citekey'
  has_and_belongs_to_many :keywords
  
  TYPES = ["article", "book", "booklet", "collection", "conference",
    "inbook", "incollection", "inproceedings", "manual", "mastersthesis",
    "misc", "patent", "phdthesis", "proceedings", "techreport", "unpublished"]
 
  def short_caption
    return citekey    
  end

  def long_caption
    capt = ""
    generate_citekey unless self.citekey != nil 
    self.title = 'No title' unless self.title != nil
    capt = self.citekey + ' - ' + title
    
    return capt
  end

  #autmatically generates a unique citekey
  def generate_citekey
    self.authors.length > 0 ? fname = self.authors[0]['last'].downcase : fname = 'anon'    
    candidate_key = fname + self.year.to_s
    candidate_key.sub!(/'/,'') #apostrophes in a name (William O'Neil) can some times screw us up
    base_key = candidate_key
    counter = 'a'   
    self.id == nil ? sid = -1 : sid = self.id #if this is a new source it won't have an id (not saved yet) and we don't need to worry that we'll retrieve the old source with the same citekey so we put in a dummy id, capish?
    while Source.count_by_sql("select count(s.id) from sources s where s.citekey = '#{candidate_key}' and s.id <> #{sid}") > 0
      #candidate_key = base_key + "(#{counter.to_s})" 
      candidate_key = base_key + counter
      counter.succ!#beautiful ruby!
    end
    self.citekey = candidate_key
  end

  # Class method hence the 'self'  
  # Pass in a single pmid and get back a single source
  # if fetch_kewords is set to true, it will return keywords entered into the
  # note body of the source
  def self.get_source_from_pmid(pmid, fetch_keywords = false)
    Source.new(PubMed.source_hash_from_pmid(pmid.chomp, fetch_keywords))
  end  


  # Class method hence the 'self'  
  # Pass in a set of pmids and get back a set of sources
  # id_text_list is a string with pubmed id values separated
  # by new lines
  # if fetch_kewords is set to true, it will return keywords entered into the
  # note body of the source
  def self.get_sources_from_pmid_list(id_text_list, fetch_keywords = false)
    sources = []
    id_lines = id_text_list.split("\n")
    id_lines.each do |id|
      src = Source.new(PubMed.source_hash_from_pmid(id.chomp, fetch_keywords))
      sources << src
    end
    
    return sources #be explicit since we just did a loop    
  end  

  # Decompose the 'author' text field into authors
  def authors
    parse_name_field(self.author)
  end
  
  # Decompose the 'editor' text field into editors
  def editors
    parse_name_field(self.editor)
  end
  
  # Utility function used to extract names of authors and editors from a text
  # field
  def parse_name_field(text)
    name_list = []
    unless text == nil
      text.split("\n").each do |au_line|
        au_line.strip!
        if au_line.empty? 
          next #Ignore empty lines
        end
        name_fragments = au_line.strip.split(',')
        name = {'first' => "-", 'last' => "-"}
        name['first'] = name_fragments.pop unless name_fragments.empty?
        name['last'] = name_fragments.pop unless name_fragments.empty?
        name_list << name
      end
    end
    return name_list    
  end
  
  def before_save
    generate_citekey unless self.citekey != ""
  end
end
