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

# Given a note, extract all the sources from it in sequence
def extract_sources_from_note(note)
  source_list = []
  # Extract references to sources in text
  note.body.scan(/\[source:(.+?)\]/) do |match|
    #$1 = citekey
    begin
      source = Source.find_by_citekey($1)
      source_list << source
    rescue
      print "extract_sources_from_note: No source with citekey #{$1}"
    end
  end
  return source_list
end


# BibTeX file generation -------------------------------------------------------
module BibTeX_export
  # Given a list of sources export the citation data to a bibtext file
  def self.export_citations(sources)
      bibtex = "#This file is automatically created by RRiki.\n"
      bibtex += "#Created on #{Time.now.localtime}\n\n"   
      #sources = Source.find source_id_list
      for src in sources 
        bibtex += "Source#{src.id}\n"
        bibtex += self.to_BibTeX(src)
        bibtex += "\n\n"
      end
      return bibtex
  end
  
  # Given a source return the citation as a bibtex string
  #if abbr_journal_names is true, then fetch the abbreviation from the journalabbr table
  def self.to_BibTeX (src)
    bib_str = "@#{src.source_type}{#{(src.citekey == nil or src.citekey == '') ? 'nolabel#{src.id.to_s}' : src.citekey},"
    for field in Source.content_columns
      fn = field.name
      unless fn == 'source_type' or fn == 'abstract' or fn == 'body'
        if fn == 'author'
          authors = src.authors
          fc = ""
          for n in 0 .. authors.length-1 do
            name = authors[n]
            fc += "#{name['first']} #{name['last']}" 
            if n < authors.length-1
              fc += ' and '
            end
          end
        else
          fc = src.send field.name
        end  
        unless fc == nil or fc == ""
          fc = self.ensure_braces_match "#{fc}"
          #fc = Journalabbr.abbreviate( journal ) if fn == 'journal' and abbr_journal_names
          fc.gsub!(/[A-Z]/) { "{#{$&}}"} if fn == 'title' #To maintain capitalization in Bibtex, we need braces
          bib_str += "\n#{fn} = { #{fc} }," 
        end
      end
    end
  
    bib_str += "\n}\n"
  end
  
  # We're not out to win the turing prize. Who knows what brace we forgot to close?
  # we just want to balance the braces so that BibTeX doesn't crash
  def self.ensure_braces_match ( instr )
    op = instr.scan("{").length
    cl = instr.scan("}").length
    
    if op > cl #not enough closes
      outstr = instr + '}'*(op - cl)
    elsif op < cl #not enough opens
      outstr = '{'*(cl - op) + instr
    else
      outstr = instr
    end
    
    return outstr
  end
end


# Word 2008 citation file generation -------------------------------------------
# This module has been inspired by bibtex2word2007
# http://sites.google.com/site/sdudah/bibtex2word2007bibliographyconverter
module Word_xml_export #Module name needs to be capitalized (constant)
  # A buch of defs to convert our source information into MS Word's xml 
  # definitions
  Opening_xml = "<?xml version=\"1.0\" ?>\n" +
                "<b:Sources SelectedStyle=\"\" xmlns:b=\"http://schemas.openxmlformats.org/officeDocument/2006/bibliography\" xmlns=\"http://schemas.openxmlformats.org/officeDocument/2006/bibliography\">"
 
  Source_type_xml = {
    "article" => '<b:SourceType>JournalArticle</b:SourceType>', 
    "book" => '<b:SourceType>Book</b:SourceType>', 
    "booklet" => '<b:SourceType>BookSection</b:SourceType>', 
    "collection" => '<b:SourceType>BookSection</b:SourceType>', 
    "conference" => '<b:SourceType>BookSection</b:SourceType>',
    "inbook" => '<b:SourceType>BookSection</b:SourceType>', 
    "incollection" => '<b:SourceType>BookSection</b:SourceType>', 
    "inproceedings" => '<b:SourceType>ConferenceProceedings</b:SourceType>', 
    "manual" => '<b:SourceType>Book</b:SourceType>', 
    "mastersthesis" => '<b:SourceType>Report</b:SourceType><b:ThesisType>Masters Thesis</b:ThesisType>',
    "misc" => '<b:SourceType>Book</b:SourceType>', 
    "patent" => '<b:SourceType>Book</b:SourceType>', 
    "phdthesis" => '<b:SourceType>Report</b:SourceType><b:ThesisType>PhD Thesis</b:ThesisType>', 
    "proceedings" => '<b:SourceType>ConferenceProceedings</b:SourceType>', 
    "techreport" => '<b:SourceType>Book</b:SourceType>', 
    "unpublished" => '<b:SourceType>Book</b:SourceType>'}

  Closing_xml = "</b:Sources>"

  def self.export_citations(sources)
      word_xml = Opening_xml
      for src in sources 
        word_xml += self.to_word2008(src)
      end
      word_xml += Closing_xml
      return word_xml
  end
  
  # Given a source return a string that is the correct xml for this source
  def self.to_word2008(src)
    word_str = "<b:Source>"
    word_str += "<b:Tag>#{(src.citekey == nil or src.citekey == '') ? 'nolabel#{src.id.to_s}' : src.citekey}</b:Tag>"
    word_str += Source_type_xml[src.source_type]
    
    #Prepare the authors fields (which includes editors) 
    word_str += "<b:Author>"
    # First do authors
    word_str += "<b:Author><b:NameList>"
    authors = src.authors
    for n in 0 .. authors.length-1 do
      name = authors[n]
      word_str += "<b:Person><b:Last>#{name['last']}</b:Last><b:First>#{name['first']}</b:First><b:Middle>#{name['middle']}</b:Middle>" 
    end    
    word_str += "</b:NameList></b:Author>"
    # Then do editors
    word_str += "<b:Editor> <b:NameList>"
    #TODO: First implement editors field in the model and views, then do it here
    word_str +="</b:NameList></b:Editor>"
    # Close up
    word_str += "</b:Author>"
    
    word_str += 
    "<b:ConferenceName>#{src.booktitle}</b:ConferenceName>" +
    "<b:Edition>#{src.edition}</b:Edition>" +
    "<b:JournalName>#{src.journal}</b:JournalName>" +
    "<b:Month>#{src.month}</b:Month>" +
    "<b:Issue>#{src.number}</b:Issue>" +
    "<b:Pages>#{src.pages}</b:Pages>" + #Watchout for double hyphens
    "<b:Publisher>#{src.publisher}</b:Publisher>" +
    "<b:Institution>#{src.school}</b:Institution>" +
    "<b:Title>#{src.title}</b:Title>" +
    "<b:Volume>#{src.volume}</b:Volume>" +
    "<b:Year>#{src.year}</b:Year>"
    word_str += "</b:Source>"    
  end
end

# This exports to the nice and flat RIS format which endnote can import
# Documentation was obtained from
# http://en.wikipedia.org/wiki/RIS_%28file_format%29
module RIS_export
  #Field tags that are exported as is
  Field2RISTag = {
    #"abstract" text, 
    "address" => 'AD', 
    #"author" varchar(255), 
    "booktitle" => 'TI', 
    #"chapter" varchar(255), 
    #"citekey" varchar(255), 
    #"edition" varchar(255), 
    "editor" => 'ED', 
    #"filing_index" varchar(255), 
    #"howpublished" varchar(255), 
    #"institution" varchar(255), 
    "journal" => 'JF', 
    #"month" varchar(255), #Handled through Y1
    "number" => 'IS', 
    #"organization" varchar(255), 
    #"pages" varchar(255), #Handled by SP,EP
    "publisher" => 'PB', 
    #"school" varchar(255), 
    #"series" varchar(255), 
    "title" => 'T1', 
    #"source_type" varchar(255), 
    #"url" varchar(255), 
    "volume" => 'VL', 
    #"year" integer,#Handled through Y1 
    #"body" text, "created_at" datetime, "updated_at" datetime
    }    
  # How to convert our types to RIS TY codes
  SourceType2RIS = {
    "article" => 'JOUR', 
    "book" => 'BOOK', 
    #"booklet" => 'BOOK', 
    #"collection", 
    "conference" => 'CONF',
    "inbook" => 'CHAP', 
    "incollection" => 'CONF', 
    "inproceedings" => 'CONF', 
    #"manual" => 'GEN', 
    "mastersthesis" => 'THES',
    "misc" => 'GEN', 
    "patent" => 'PAT', 
    "phdthesis" => 'THES', 
    "proceedings" => 'CONF', 
    "techreport" => 'RPRT', 
    "unpublished" => 'UNPB'
  }

  def self.export_citations(sources)
      ris = ""
      for src in sources.uniq 
        ris += self.to_RIS(src)
      end
      return ris
  end
  
  # Given a source return the citation as a RIS string
  def self.to_RIS(src)
    ris = "TY  - #{SourceType2RIS[src.source_type] == nil ? 'GEN' : SourceType2RIS[src.source_type]}\n"
    for field in Source.content_columns
      fn = field.name
      if Field2RISTag[fn] != nil
        ris += "#{Field2RISTag[fn]}  - #{src.send field.name}\n" 
      end
    end
    #Print year (find a way to bring in the month?)
    ris += "PY  - %04d///\n" % src.year.to_i
    #Print Authors
    authors = src.authors
    for n in 0 .. authors.length-1 do
      name = authors[n]
      ris += "AU  - #{name['last']}, #{name['first']} #{name['middle']}\n" 
    end
    #Pages
    # Takes care of case where we have two dashes e.g. 23--45
    pg = src.pages
    begin
      ris += "SP  - #{pg[0...pg.index('-')]}\n" #finds 23
      ris += "EP  - #{pg.reverse[0...pg.reverse.index('-')].reverse}\n" #finds 45, operating on reversed string
    rescue
      ris += "SP  - #{pg}\n"
    end
  
    ris += "ER  -\n"
  end
  
end