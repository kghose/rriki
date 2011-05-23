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

class Keyword < ActiveRecord::Base
  belongs_to :keyword
  has_many :keywords, :order => 'name', :dependent => :destroy
  has_and_belongs_to_many :notes, :order => 'date DESC, title'
  has_and_belongs_to_many :sources, :order => 'citekey'
  
  def caption()
    return name
  end  
  
  # Find only those keywords which have no parents
  def self.find_root_keys()
    self.find(:all, :conditions => 'keyword_id is NULL', :order => 'name')
  end
  
  # For this keyword AND ALL IT'S CHILDREN find all the associated notes, sources
  def all_descendant_items
    all_notes = self.notes
    all_sources = self.sources
    child_keys = self.keywords
    for key in child_keys
      all_notes += key.notes unless key.notes == nil
      all_sources += key.sources unless key.sources == nil
    end
    return all_notes.sort {|a,b| a.date <=> b.date}.reverse, all_sources.sort! {|a,b| a.citekey <=> b.citekey}
  end

  # For this keyword, traverse up the parent chain until you hit a nil (i.e.
  # root node) This is needed to fill out path_text before we save the record
  # path_text saves time when we want to know where this keyword is in the tree
  # and when we are doing auto complete
  def compute_path
    path = "/#{name}"
    this_key = keyword
    while this_key != nil
      path = "/#{this_key.name}#{path}"
      this_key = this_key.keyword
    end
    return path
  end
  
  # Go through all the children, updating the path_text as required.
  # Expensive operation
  def inform_children
    keys = self.keywords
    for key in keys
      key.path_text = key.compute_path
      key.save
      key.inform_children
    end
  end
  
  # This returns us the parent path by removing out the last bit of path_text
  # before the final /.
  def parent_path_text
    path_text[0...-(name.length)]
  end
  
  # We want this information to be saved with the keyword at creation/update
  def before_save
    self.path_text = compute_path
  end
  
  # We can only do this after the keyword in question has been saved
  def after_save
    inform_children    
  end
end