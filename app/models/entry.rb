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

class Entry < ActiveRecord::Base
  has_and_belongs_to_many :tags, :order => :name
  
  # Get all entries but grouped by year and then month
  def self.grouped_entries    
    entries = Entry.find :all, :order => 'date DESC'
    # http://www.therailsway.com/2007/1/21/more-idiomatic-ruby
    # http://api.rubyonrails.org/classes/Enumerable.html
    # Ain't Ruby grand?
    entries.group_by do |entry|
      entry.date.year
    end
  end
end


