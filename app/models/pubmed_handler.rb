#   RRiki is a notes and citations management software
#   Copyright (C) 2009 - Kaushik Ghose - kaushik.ghose@gmail.com
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

#This file contains a module to grab data from the pubmed database using entrez eutils

require 'net/http'	
module PubMed
  
  module_function
  
  HOST = "www.ncbi.nlm.nih.gov"
  PATH = "/entrez/utils/pmfetch.fcgi?tool=rriki&email=kaushik.ghose@gmail.com&mode=xml&report=medline&db=PubMed&id="
    
  # Given a pub med id fetch the data and return it formatted as 
  # a hash suitable for using to create a source
  # Refering to code from bioruby.org
  # http://cvs.open-bio.org/cgi-bin/viewcvs/viewcvs.cgi/bioruby/lib/bio/io/pubmed.rb?rev=1.12&cvsroot=bioruby&content-type=text/vnd.viewcvs-markup
  # Make sure the query method is xml
  def source_hash_from_pmid(id, fetch_keywords = true)
    http = Net::HTTP.new(HOST)
    response = http.request_get(PATH + id.to_s)
    result = response.body    
    source_hash_from_pubmed_xml_reply(result, fetch_keywords)
  end

    
  # Given a reply string from PubMed's pmfetch parse it and return
  # a hash we can use to initialize a source
  def source_hash_from_pubmed_xml_reply(str, fetch_keywords = true)
    print "\nPubmed says --------------------------------\n"
    print str
    print "\n--------------------------------------------\n"
    require 'rexml/document'
    month_names = {
    "Jan" => "January",
    "Feb" => "February",
    "Mar" => "March",
    "Apr" => "April",
    "May" => "May",
    "Jun" => "June",
    "Jul" => "July",
    "Aug" => "August",
    "Sep" => "September",
    "Oct" => "October",
    "Nov" => "November",
    "Dec" => "December"
    }
    docu = REXML::Document.new(str.force_encoding('UTF-8'))
    #We convert to utf8 because I kept getting a mysterious 
    # #<Encoding::CompatibilityError: incompatible encoding regexp match (UTF-8 regexp with ASCII-8BIT string)>
    #error at this point for a very few records. 
    citation = docu.root.elements["PubmedArticle[1]/MedlineCitation/Article"].elements
    keyword = docu.root.elements["PubmedArticle[1]/MedlineCitation/MeshHeadingList"]
    authorelements = docu.root.elements["PubmedArticle[1]/MedlineCitation/Article/AuthorList"]
    
    source_fields = {	"source_type" => "article" }#For now. PubMed seems to only retrieve journal articles
    #These are REXML elements, not text!
    source_field_xml = {
    "title" => citation["ArticleTitle"],
    "journal" => citation["Journal/Title"],
    "pages" => citation["Pagination/MedlinePgn"],
    "volume" => citation["Journal/JournalIssue/Volume"],
    "number" => citation["Journal/JournalIssue/Issue"],
    "year" => citation["Journal/JournalIssue/PubDate/Year"],
    "month" => citation["Journal/JournalIssue/PubDate/Month"],
    "abstract" => citation["Abstract/AbstractText"],
    }
    source_field_xml.each {|key,value| value ? source_fields[key] = value.text : source_fields[key] = "" }		
    
    #a little post processing
    source_fields["title"] ? source_fields["title"].strip! : ''
    source_fields["title"] ? source_fields["title"].chomp!('.') : '' #get rid of annoying periods in source title
    source_fields["journal"] ? source_fields["journal"].strip! : ''
    source_fields["journal"] ? source_fields["journal"].chomp!('.') : '' #get rid of annoying periods in journal title
    source_fields["month"] ? source_fields["month"] = month_names[source_fields["month"]] : '' #convert month abbreviation to full
    
    #more complicated fields
    
    #keywords.
    if keyword and fetch_keywords
      source_fields["body"] = "Keywords\n-------\n"
      keyword.each_element { |elem|
        keyw = elem.elements["DescriptorName"].texts
        source_fields["body"] += "* [#{keyw}][keyword:#{keyw.to_s.gsub(" ","_")}]\n"
      } 
    end
    
    #Author list
    source_fields["author"] = ""
    authorelements.each_element { |elem|
      first_name_and_initials = ""
      first_name_and_initals = "#{elem.elements["ForeName"].text}" if elem.elements["ForeName"]
      first_name_and_initals = "#{elem.elements["FirstName"].text}" if elem.elements["FirstName"]
      # We don't bother putting in name if we don't have the last name
      source_fields["author"] += "#{elem.elements["LastName"].text}, #{first_name_and_initals}\n" if elem.elements["LastName"]
    } if authorelements
    
    return source_fields #return the hash, make it independent of the Source class, but directly usable
  end

end