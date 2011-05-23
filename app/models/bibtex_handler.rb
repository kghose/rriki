#   RRiki is a notes and citations management software
#   Copyright (C) 2006 - Kaushik Ghose - kaushik.ghose@gmail.com
#	
#    This file is part of RRiki.
#
#    RRiki is free software; you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation; either version 2 of the License, or
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

# BibTex handling used to be under helpers, but this is wrong - the
# methods here are not for views, but are rather internal and affect
# The source model specifically

## Given a note, extract all the sources from it in sequence
#def extract_sources_from_note(note)
#  source_list = []
#  # Extract references to sources in text
#  note.body.scan(/\[source:(.+?)\]/) do |match|
#    #$1 = citekey
#    begin
#      source = Source.find_by_citekey($1)
#      source_list << source
#    rescue
#      print "extract_sources_from_note: No source with citekey #{$1}"
#    end
#  end
#  return source_list
#end
#
## BibTeX file generation -------------------------------------------------------
## Given a list of sources export the citation data to a bibtext file
#def export_citations(sources)
#    bibtex = "#This file is automatically created by RRiki.\n"
#    bibtex += "#Created on #{Time.now.localtime}\n\n"   
#    #sources = Source.find source_id_list
#    for src in sources 
#      bibtex << "Source#{src.id}\n"
#      bibtex << to_BibTeX(src)
#      bibtex << "\n\n"
#    end
#    return bibtex
#end
#
## Given a source return the citation as a bibtex string
##if abbr_journal_names is true, then fetch the abbreviation from the journalabbr table
#def to_BibTeX (src)
#  bib_str = "@#{src.source_type}{#{(src.citekey == nil or src.citekey == '') ? 'nolabel#{src.id.to_s}' : src.citekey},"
#  for field in Source.content_columns
#    fn = field.name
#    unless fn == 'source_type' or fn == 'abstract' or fn == 'body'
#      if fn == 'author'
#        authors = src.authors
#        fc = ""
#        for n in 0 .. authors.length-1 do
#          name = authors[n]
#          fc += "#{name['first']} #{name['last']}" 
#          if n < authors.length-1
#            fc += ' and '
#          end
#        end
#      else
#        fc = src.send field.name
#      end  
#      unless fc == nil or fc == ""
#        fc = ensure_braces_match "#{fc}"
#        #fc = Journalabbr.abbreviate( journal ) if fn == 'journal' and abbr_journal_names
#        fc.gsub!(/[A-Z]/) { "{#{$&}}"} if fn == 'title' #To maintain capitalization in Bibtex, we need braces
#        bib_str += "\n#{fn} = { #{fc} }," 
#      end
#    end
#  end
#
#  bib_str += "\n}\n"
#end
#
## We're not out to win the turing prize. Who knows what brace we forgot to close?
## we just want to balance the braces so that BibTeX doesn't crash
#def ensure_braces_match ( instr )
#  op = instr.scan("{").length
#  cl = instr.scan("}").length
#  
#  if op > cl #not enough closes
#    outstr = instr + '}'*(op - cl)
#  elsif op < cl #not enough opens
#    outstr = '{'*(cl - op) + instr
#  else
#    outstr = instr
#  end
#  
#  return outstr
#end
#
## Word 2008 citation file generation -------------------------------------------
## This module has been inspired by bibtex2word2007
## http://sites.google.com/site/sdudah/bibtex2word2007bibliographyconverter
#module word_xml_export
#  # A buch of defs to convert our source information into MS Word's xml 
#  # definitions
#  opening_xml = "<?xml version=\"1.0\" ?>\n"
#  opening_xml += "<b:Sources SelectedStyle=\"\" xmlns:b=\"http://schemas.openxmlformats.org/officeDocument/2006/bibliography\" xmlns=\"http://schemas.openxmlformats.org/officeDocument/2006/bibliography\">"
# 
#  source_type_xml = {
#    "article" => '<b:SourceType>JournalArticle</b:SourceType>', 
#    "book" => '<b:SourceType>Book</b:SourceType>', 
#    "booklet" => '<b:SourceType>BookSection</b:SourceType>', 
#    "collection" => '<b:SourceType>BookSection</b:SourceType>', 
#    "conference" => '<b:SourceType>BookSection</b:SourceType>',
#    "inbook" => '<b:SourceType>BookSection</b:SourceType>', 
#    "incollection" => '<b:SourceType>BookSection</b:SourceType>', 
#    "inproceedings" => '<b:SourceType>ConferenceProceedings</b:SourceType>', 
#    "manual" => '<b:SourceType>Book</b:SourceType>', 
#    "mastersthesis" => '<b:SourceType>Report</b:SourceType><b:ThesisType>Masters Thesis</b:ThesisType>',
#    "misc" => '<b:SourceType>Book</b:SourceType>', 
#    "patent" => '<b:SourceType>Book</b:SourceType>', 
#    "phdthesis" => '<b:SourceType>Report</b:SourceType><b:ThesisType>PhD Thesis</b:ThesisType>', 
#    "proceedings" => '<b:SourceType>ConferenceProceedings</b:SourceType>', 
#    "techreport" => '<b:SourceType>Book</b:SourceType>', 
#    "unpublished" => '<b:SourceType>Book</b:SourceType>'}
#
#  closing_xml = "</b:Sources>"
#
#  def export_citations(sources)
#      word_xml = opening_xml
#      for src in sources 
#        word_xml += to_word2008(src)
#      end
#      return word_xml
#  end
#  
#  # Given a source return a string that is the correct xml for this source
#  def to_word2008(src)
#    word_str = "<b:Source>"
#    word_str += "<b:Tag>#{(src.citekey == nil or src.citekey == '') ? 'nolabel#{src.id.to_s}' : src.citekey}</b:Tag>"
#    word_str += source_type_xml[src.source_type]
#    
#    #Prepare the authors fields (which includes editors) 
#    word_str += "<b:Author>"
#    # First do authors
#    word_str += "<b:Author><b:NameList>"
#    authors = src.authors
#    for n in 0 .. authors.length-1 do
#      name = authors[n]
#      word_str += "<b:Person><b:Last>#{name['last']}</b:Last><b:First>#{name['first']}</b:First><b:Middle>#{name['middle']}</b:Middle>" 
#    end    
#    word_str += "</b:NameList></b:Author>"
#    # Then do editors
#    word_str += "<b:Editor> <b:NameList>"
#    #TODO: First implement editors field in the model and views, then do it here
#    word_str +="</b:NameList></b:Editor>"
#    # Close up
#    word_str += "</b:Author>"
#    
#    word_str += 
#    "<b:ConferenceName>#{src.booktitle}</b:ConferenceName>" +
#    "<b:Edition>#{src.edition}</b:Edition>" +
#    "<b:JournalName>#{src.journal}</b:JournalName>" +
#    "<b:Month>#{src.month}</b:Month>" +
#    "<b:Issue>#{src.number}</b:Issue>" +
#    "<b:Pages>#{src.pages}</b:Pages>" + #Watchout for double hyphens
#    "<b:Publisher>#{src.publisher}</b:Publisher>" +
#    "<b:Institution>#{src.school}</b:Institution>" +
#    "<b:Title>#{src.title}</b:Title>" +
#    "<b:Volume>#{src.volume}</b:Volume>" +
#    "<b:Year>#{src.year}</b:Year>"
#    word_str += "</b:Source>"    
#  end
#end


# I should consider whether to obsolete the functions below --------------------

## This has functions to write to/read from bibtex. 
## This code used to be in source.rb and sources_helper.rb
## but its better here
#module BibtexExport
#
#  ENTRY_HEADER = '#RRIKI_SOURCE_ID'
#  BIBTEX_FILENAME = 'rriki.bib'
#
#  #Exports all the sources to the bib file. This is a module method rather than
#  #something that should be inherited, because it doesn't make sense from the
#  #point of view of an individual source instance
#  def BibtexExport.saveAllBibTeX(abbr_j_names = true)
#		bibtex = "#Warning: This file is automatically created by RRiki.\n"
#		bibtex += "#Any changes to it will be overwritten\n"
#		bibtex += "#Created on #{Time.now.localtime}\n\n"		
#		sources = Source.find :all, :order => "citekey"
#		for src in sources 
#			bibtex << "#{ENTRY_HEADER}#{src.id}\n"
#			bibtex << src.to_BibTeX(abbr_j_names)
#			bibtex << "\n\n"
#		end
#		file = open(BIBTEX_FILENAME, 'w') 
#		if file
#			file.puts bibtex
#			file.close
#			return true
#		else
#			return false
#		end
#  end
#  
#  #this function is invoked each time a source is saved - from after_save
#  #It reads in the bibtex file, finds the appropriate entry, deletes it and rewrites with 
#  #the present data
#  #at this stage, we either have an automatically generated citekey, or an existing one (since we call this after save)
#  #and citekey generation is done before save
#  #If there is no matching citekey then a new entry is created.
#  #The new entry violates the alphabetical order... so sue me, bibtex doesn'care!
#  #If remove = true we are deleting the source and its entry needs to be removed
#  def updateBibTeX(remove = false)
#    unless FileTest.exists?( 'rriki.bib' )
#      return BibtexExport.saveAllBibTeX
#    end	
#    search_string = "#{ENTRY_HEADER}#{self.id}" #
#    remove == false ? replace_string = "#{ENTRY_HEADER}#{self.id}\n" + self.to_BibTeX + "\n\n" : replace_string = ""
#    originalfilestr = IO.readlines(BIBTEX_FILENAME).join
#    newfilestr = originalfilestr.gsub!(Regexp.new("^#{search_string}[^#]*"), replace_string)
#    newfilestr = originalfilestr + replace_string if newfilestr == nil #if it is nil then we need to add a new entry...
#    file = open(BIBTEX_FILENAME,"w") << newfilestr
#    file.close
#    return true
#  end
#
#  #bibtex
#  #if abbr_journal_names is true, then fetch the abbreviation from the journalabbr table
#  def to_BibTeX (abbr_journal_names = true)
#    bib_str = "@#{source_type}{#{(citekey == nil or citekey == '') ? "nolabel#{id.to_s}" : citekey},"
#    for field in Source.content_columns
#      fn = field.name
#      unless fn == 'citekey' or fn == 'source_type' or fn == 'abstract' or fn == 'note_text'
#        fc = send field.name
#        unless fc == nil or fc == ""
#          fc = ensure_braces_match "#{fc}"
#          fc = Journalabbr.abbreviate( journal ) if fn == 'journal' and abbr_journal_names
#          fc.gsub!(/[A-Z]/) { "{#{$&}}"} if fn == 'title' #To maintain capitalization in Bibtex, we need braces
#          bib_str += "\n#{fn} = { #{fc} }," 
#        end
#      end
#    end
#  
#    bib_str += "\n}\n"
#  end
#  
#  # We're not out to win the turing prize. Who knows what brace we forgot to close?
#  # we just want to balance the braces so that BibTeX doesn't crash
#  def ensure_braces_match ( instr )
#    op = instr.scan("{").length
#    cl = instr.scan("}").length
#    
#    if op > cl #not enough closes
#      outstr = instr + '}'*(op - cl)
#    elsif op < cl #not enough opens
#      outstr = '{'*(cl - op) + instr
#    else
#      outstr = instr
#    end
#    
#    return outstr
#  end
#  
#end
#
#
##RRiki does not use BibTeX as its primary storage medium. This module is merely meant
##to parse an existing BibTeX file and return an array of information that can be inserted into
##RRiki's database
#
## This code is adapted from Pages-Bibtex by 
## Thomas Counsell tamc2@cam.ac.uk and Jon Hall jgh23@open.ac.uk
#
## call by invoking BibFile.new( IO.readlines("#{document.bibliography_file_name}.bib").join )
## 
## e.g.
## bbl = BibFile.new( IO.readlines("../../rriki.bib").join )
## bbl.each {|key,bibitem|  puts key}
#
#class BibFile
#  
#  include Enumerable
#  
#  def initialize( filestring = nil )
#    @items = Hash.new
#    parse( filestring ) if filestring
#  end
#  
#  def each 
#    @items.each { |key, bibitem| yield key, bibitem }
#  end
#  
#  def []( key )
#    return @items[ key ]
#  end
#  
#  #kaushik.ghose@gmail.com 2006.01.06
#  def length
#    return @items.length
#  end
#  
#  private
#  
#  def parse( filestring )
#    filestring.scan(/^@[^@]*/) do |itemstring|
#      bibitem = BibItem.new( itemstring )
#      @items[ bibitem.key ] = bibitem
#    end
#  end
#end
#
#class BibItem
#  
#  attr_reader :type, :key, :fields, :authors, :cite_order, :rriki_raw_author_text
#  attr_accessor :sort_order
#  
#  def initialize( itemstring )
#    @fields = Hash.new
#    parse itemstring
#    parse_authors	
#  end
#  
#  def []( field )
#    value = @fields[ field.to_s.downcase ]
#    value != nil ? value : ""
#  end
#  
#  def []=( field, value )
#    @fields[ field.to_s.downcase ] = value
#  end
#  
#  def shortauthor( max = 3 )
#    format_list( authors.map { |fullname| fullname.first }, max )
#  end
#  
#  def method_missing( method, *args )
#    self[ method ]
#  end
#  
#  def cite_order=( value )
#    @cite_order ||= value # So that only takes earliest citation
#  end
#  
#  private
#  
#  #2006.01.10 kaushik.ghose@gmail.com added (.|\n) to handle newlines in fields
#  def parse( itemstring )
#    itemstring =~ /^@(.*)\{(.*?),/
#    @type, @key = $1, $2 
#    itemstring.scan(/(\w+)\s*=\s*\{((.|\n)*?)\}[,}]/) do |field,value|
#      @fields[ field.downcase ] = value
#    end
#  end
#  
#  def parse_authors
#    @authors = author ? author.split(/and/i).map { |fullname| fullname.strip.split(/,/).map { |name| name.strip } } : [["Anon",""]]
#    @rriki_raw_author_text = author ? author.gsub(/ and /,"\n") : "Anon" #kaushik.ghose@gmail.com 2006.01.06
#  end
#  
#  def format_list( elements, max = 3, tail = ' et al.' )
#    return "" if elements.empty?
#    return elements.first if elements.size == 1
#    if elements.size > max
#      return elements.first+tail
#    else
#      return elements[0,elements.size-1].join(', ')+' and '+elements.last
#    end
#  end
#end
#
#class BblFile
#  include Enumerable
#  
#  def initialize( filestring = nil)
#    @items = []
#    parse( filestring ) if filestring
#  end
#  
#  def each 
#    @items.each { |citekey, citeref| yield citekey, citeref }
#  end
#  
#  private
#  
#  #I want to parse a bbl entry into citekey and citeref, if it exists
#  def parse( filestring )
#    filestring.scan(/\\bibitem(\[(.*?)\])?\{(.*?)\}/m) do |match|
#      @items << [$3, $2 || (@items.size+1).to_s ]
#    end
#  end	
#end
#
##~ class Source
##~ attr_reader :title, :year
##~ attr_writer :title, :year
##~ end
#
##~ bbl = BibFile.new( IO.readlines("../../murat.bib").join )
##~ bbl.each do |key,bibitem| 
#  #~ puts bibitem.type
##~ end
