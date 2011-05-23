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

class TagsController < ApplicationController
  # GET /tags/1
  # GET /tags/1.xml
  def show
    tag = Tag.find(params[:id])
    entries = tag.entries
    render :partial => "entries/list", :locals => {:entries => entries}
  end
  
  def get_entries_with_no_tag
    entries = Entry.find(:all, 
       :conditions => "id not in (select entry_id from entries_tags)",
       :order => 'date DESC')
    render :partial => "entries/list", :locals => {:entries => entries}        
  end

end
