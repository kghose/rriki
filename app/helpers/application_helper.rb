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

# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  # Some stuff for the bluecloth/markdown censor
  @@censor_strings = []
  @@censor_strings << ['^','<UPCARET>']
  @@censor_strings << ['`','<BACKTICK>']
  @@censor_strings << ['_','<UNDERSLASH>']
  
  require 'bluecloth'
  
  # This returns displayable html of the 'body' field that has 
  # 1. the markdown converted to html (via BlueCloth)
  # 2. links to other nodes worked in (via link_to_remote tags)
  def body_html(model, divid = nil)
    return nil if model.body == nil

    text = model.body
    
    # Hacks to prevent Markdown and ASCIIMathML from fighting with each other
    text = censor_text_for_markdown(text)    
        
    # Links to notes
    text.gsub!(/\[(.+?)\]\[note:(\d+?)\]/) do |match|
      #$1 = link_txt
      #$2 = id
      begin
        note = Note.find_by_id($2)
        link_to_remote $1, 
                     :url => note_path(note), 
                     :method => :get,
                     :html => {:title => "#{note.title} (note:#{$2})"}
      rescue
        "#{$1} [*No note with id #{$2}*]"
      end
    end
        
    # Links to sources
    text.gsub!(/\[source:(.+?)\]/) do |match|
      #$1 = citekey
      begin
        source = Source.find_by_citekey($1)
        link_to_remote "#{source.citekey}", 
                     :url => source_path(source), 
                     :method => :get,
                     :html => {:title => "#{source.title}"}
      rescue
        "[*No source with citekey #{$1}*]"
      end
    end
    
    text = markdown(text)
    # Hacks to prevent Markdown and ASCIIMathML from fighting with each other
    text = uncensor_text_for_markdown(text)    
    return text
  end
  
  # Markdown encroaches on some of ASCIIMathML's territory. These two functions
  # try and encode any characters that have a special meaning for ASCIIMath and
  # markdown, so that markdown leaves them alone
  def censor_text_for_markdown(text)
    for n in 0...@@censor_strings.length
       text.gsub!(@@censor_strings[n][0], @@censor_strings[n][1])      
    end
    return text
  end
  
  def uncensor_text_for_markdown(text)
    for n in 0...@@censor_strings.length
       text.gsub!(@@censor_strings[n][1], @@censor_strings[n][0])      
    end
    return text
  end
  
  
  def history_list
    if not RrikiParam.exists?(:key => 'history')
      initialize_history #found in application_controller
    end
    history_param = RrikiParam.find_by_key('history')
    history_dict = history_param.value #Should unserialize to a dictionary
    pos = history_dict['position']
    history = history_dict['history']
    hlist = []
    history.each do |his|
      this_option = ["#{his['long caption']}","#{his['item type']}:#{his['item id']}"]
      hlist << this_option
    end
    return hlist    
  end
end
