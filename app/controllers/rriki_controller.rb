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

class RrikiController < ApplicationController
  # This is the main page we come in to when we run RRiki
  def index
    @keys = Keyword.find_root_keys
  end
  
  # return all items with no keyword
  def items_with_no_keyword
    notes = Note.find(:all, :conditions => "id not in (select note_id from keywords_notes)")
    sources = Source.find(:all, :conditions => "id not in (select source_id from keywords_sources)")

    render :partial => 'list', 
           :locals => {:key => nil, :notes => notes, :sources => sources}
  end
  
  # :id -> specifies id of keyword. This controller returns all items linked
  # to this keyword
  def items_with_keyword
    key = Keyword.find(params[:id])
    notes = key.notes
    sources = key.sources
    render :partial => 'list', 
           :locals => {:key => key, :notes => notes, :sources => sources}
  end

  # :id -> specifies id of keyword. This controller returns all items linked
  # to this keyword and its children
  def items_with_keyword_including_child_keywords
    key = Keyword.find(params[:id])
    notes, sources = key.all_descendant_items
    render :partial => 'list', 
           :locals => {:key => key, :notes => notes, :sources => sources}
  end
  
  # 
  def search
    search_txt = '%' + params[:search]['text'] + '%'
    note_conditions = ['title LIKE ? OR body LIKE ?', search_txt, search_txt]
    source_conditions = ['title LIKE ? OR body LIKE ? OR author LIKE ? OR abstract LIKE ?', 
          search_txt, search_txt, search_txt, search_txt]
    if params[:key_id] == nil #Find everything
      notes = Note.find(:all, :conditions => note_conditions)
      sources = Source.find(:all, :conditions => source_conditions)
    else
      key = Keyword.find(params[:key_id])
      notes = key.notes.find(:all, :conditions => note_conditions)
      sources = key.sources.find(:all, :conditions => source_conditions)
    end
    render :partial => 'list', 
           :locals => {:key => key, :notes => notes, :sources => sources, :search_text => params[:search]['text']}
  end
  
  # Clear the history
  def clear_history
    clear_history_list
    render :update do |page|
      page.replace_html 'history', :partial => 'rriki/history'
    end    
  end

  # The select box returns a coded string under params['history_sel']
  # The coded string looks like 'Note:569' or 'Source:941'
  def select_item_in_history
    controller, id = params['history_sel'].split(':')
    redirect_to :controller => controller.pluralize, :action => 'show', :id => id
  end
  
  # miscellaneous information about RRiki
  def infohelp
    render :update do |page|    
      page.replace_html 'item-div', :partial => 'infohelp'
      page.replace_html 'item-keyword-div', ''
    end    
  end
end