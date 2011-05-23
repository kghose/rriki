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

class KeywordsController < ApplicationController
  def index
    @keys = Keyword.find_root_keys
  end

  # If you try to use edit (in the view) Rails will try and make up a strange
  # Path by itself...
  def edit_key
    key = Keyword.find(params[:id])
    render :partial => 'edit_key', 
      :locals => {:key => key, :parent_key => params[:parent_key],
                  :thisdivid => params[:thisdivid],
                  :parent_divid => params[:parent_divid]}
  end
    
  def update
    key = Keyword.find(params[:id])
    key.update_attributes(params[:keyword])
    render :partial => 'show_key', 
      :locals => {:key => key, :parent_key => params[:parent_key],
                  :thisdivid => params[:thisdivid],
                  :parent_divid => params[:parent_divid]}
  end
  
  # This is a bit like add_child...
  def delete
    key = Keyword.find(params[:id])
    key.destroy
    if params[:parent_id] != nil
      key = Keyword.find(params[:parent_id])
      keys = key.keywords
    else
      # A root key was deleted
      key = nil # Our partial (keyword/_list) expects a nil parent when displaying root 
      keys = Keyword.find_root_keys
    end
    render :partial => 'list', :locals => {:parent_key => key, :keys => keys}    
  end
  
  def add_child
    if params[:id] != nil
      key = Keyword.find(params[:id])
      key.keywords.create(params[:keyword])
      keys = key.keywords
    else
      # A new root key being added
      new_key = Keyword.new(params[:keyword])
      new_key.save # Error checking?
      key = nil # Our partial (keyword/_list) expects a nil parent when displaying root 
      keys = Keyword.find_root_keys
    end
    render :partial => 'list', :locals => {:parent_key => key, :keys => keys}
  end
  
  def expand
    key = Keyword.find(params[:id])
    keys = key.keywords
    render :partial => 'list', :locals => {:parent_key => key, :keys => keys}
  end
  
  def contract
    render :text => ""
  end
  
  # Adds an existing keyword to the note. Parameters passed are
  # :itemid
  # :itemtype -> pertaining to the item we have to add the keyword to
  # :divid - the id of the div we need to update
  # keyword["path_text"]
  def add_keyword
    itemtype = params[:itemtype]
    itemid = params[:itemid]
    item = itemtype.constantize.find(itemid) # Error checking?
    
    key_to_add = Keyword.find_by_path_text(params[:keyword]["path_text"])
    item.keywords << key_to_add unless (key_to_add == nil) or (item.keywords.include? key_to_add)
    render :partial => 'keywords/linked_keywords', 
      :locals => {:keys => item.keywords, :item => item, :divid => params[:divid]}
  end
  
  # Adds an existing keyword to the note. Parameters passed are
  # :id -> id of the keyword
  # :itemid 
  # :itemtype -> pertaining to the item we have to add the keyword to
  # :divid - the id of the div we need to update
  def remove_keyword
    itemtype = params[:itemtype]
    itemid = params[:itemid]
    item = itemtype.constantize.find(itemid) # Error checking?
    
    key_to_remove = Keyword.find(params[:id])
    #item.keywords << key_to_add unless (key_to_add == nil) or (item.keywords.include? key_to_add)
    item.keywords.delete key_to_remove
    render :partial => 'keywords/linked_keywords', 
      :locals => {:keys => item.keywords, :item => item, :divid => params[:divid]}
  end
  
  # Moves an existing keyword and all its children to either root or under an
  # existing keyword. Updates the text in the items pane and redraws the 
  # Entire keyword tree
  # :childid -> id of the keyword to be moved
  # :newparentid -> id of new parent keyword 
  def move_keyword
    if params[:newparentid] != '-1'
      new_parent_key = Keyword.find(params[:newparentid])
    else
      new_parent_key = nil
    end
    key = Keyword.find(params[:childid])
    key.keyword = new_parent_key
    key.save
    keys = Keyword.find_root_keys
    render :update do |page|    
      page.replace_html 'key-main', :partial => 'keywords/list', :locals => {:parent_key => nil, :keys => keys}
      page.replace_html 'currentparentpath', key.parent_path_text
    end
  end
end
