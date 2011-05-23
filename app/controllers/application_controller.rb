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

# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  #protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password
    
  # auto_complete_for :keyword, :path_text is messed up. Probably the inline
  # rendering of the result list is broken. Hence we write our own code and
  # use a partial
  def auto_complete_for_keyword_path_text
    @keys = Keyword.find(:all, 
          :conditions => "LOWER(path_text) LIKE '%#{params[:keyword]["path_text"]}%'",
          :order => 'path_text',
          :limit => 10)
    render :partial => 'keywords/key_auto_complete', :locals => {:keys => @keys}
  end
  
  # Attempt to create a history handler-----------------------------------------
  # Use this when no 'history' parameter exists 
  def initialize_history
    history_param = RrikiParam.new
    history_param.key = 'history'
    history_dict = {'history' => [], 'position' => -1}        
    history_param.value = history_dict
    history_param.save
  end
 
  # Add this item to the history list
  def add_to_history(item)
    if not RrikiParam.exists?(:key => 'history')
      initialize_history
    end
    
    history_param = RrikiParam.find_by_key('history')
    item_type = item.class.name
    item_id = item.id
    item_controller = item.class.to_s.tableize
    short_caption = item_type[0...1] 
    long_caption = item.long_caption
    history_dict = history_param.value #Should unserialize to a dictionary

    # Check out if we already have this item in the list
    history_dict['history'].each do |his|
      if his['item type'] == item_type and his['item id'] == item_id
        return
      end
    end
    
    pos = history_dict['position']
    history_dict['history'] << {'item type' => item_type, 'controller' => item_controller, 'item id' => item_id, 
      'short caption' => short_caption, 'long caption' => long_caption}
    history_dict['position'] = -1
    history_param.value = history_dict
    history_param.save
  end

  # Clear the history list
  def clear_history_list
    if not RrikiParam.exists?(:key => 'history')
      initialize_history
    end
    history_param = RrikiParam.find_by_key('history')
    history_dict = history_param.value #Should unserialize to a dictionary
    history_dict['history'] = []
    history_param.value = history_dict
    history_param.save    
  end

end