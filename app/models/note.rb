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

require 'model_methods'

class Note < ActiveRecord::Base
  default_scope :order => 'date DESC, title'
  has_and_belongs_to_many :keywords
  # Search conventions:
  
#  def self.search(query)
#    :conditions => [ "user_name = ? AND password = ?", user_name, password ])
#
#    
#    
#    if !query.to_s.strip.empty?
#      nonquoted = query.gsub(/\"(.*?)\"/,"") #the parts of the query without quotes
#      tokens = nonquoted.split.collect {|c| "%#{c.downcase}%"}
#      query.scan(/\"(.*?)\"/) {|c| tokens << "%#{c}%"} #the quoted parts        
#      result = find_by_sql(["select n.* from notes n where #{ (["(lower(n.title) like ? or lower(n.note_text) like ?)"] * tokens.size).join(" and ") } order by note_date desc, title", *(tokens * 2).sort])
#    else
#      []
#    end 
#  end

#  def parse_search

  def short_caption
    return title[0...5]
  end
  
  def long_caption
    return title
  end
  
end
