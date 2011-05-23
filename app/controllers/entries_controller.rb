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

class EntriesController < ApplicationController
  
  # GET /entries
  # GET /entries.xml
  def index
    @entries = Entry.grouped_entries
  end
  
  def new
    @entry = Entry.new
    @entry.date = DateTime.now
  end
  
  def create
    entry = Entry.new(params[:entry])
    entry.save # Error checking?
    redirect_to :action => 'index'
  end

  def edit
    @entry = Entry.find(params[:id])
  end

  def update
    entry = Entry.find(params[:id])
    entry.update_attributes(params[:entry]) # Error checking?
    redirect_to :action => 'index', :anchor => "entry#{entry.id}"  
  end

end

class Dummy

  def show_by_date
    st_date = Date.parse(params[:start_date])
    params[:end_date] != nil ? nd_date = Date.parse(params[:end_date]) : nd_date = st_date + 1
    date_range = st_date..nd_date
    @entries = Entry.all(:conditions =>  {:date => date_range}, 
                         :order => "date DESC")
    render :partial => 'list'
  end

  # GET /entries/1
  # GET /entries/1.xml
  def show
    entry = Entry.find(params[:id])
    render :partial => 'show', :locals => {:entry => entry}
  end

  def new
    entry = Entry.new
    entry.date = DateTime.now
    render :update do |page|
      page.replace_html 'main', 
          :partial => 'form', 
           :locals => {:entry => entry,
                       :creating => true}
    end 
  end
  
  def edit
    entry = Entry.find(params[:id])
    render :partial => 'form', 
           :locals => {:entry => entry,
                       :creating => false}
  end

  def create
    entry = Entry.new(params[:entry])
    entry.save # Error checking?
    render :update do |page|    
      page.replace_html 'main', :partial => 'show', :locals => {:entry => entry}
      page.replace_html 'diary-tags', :partial => "tags/list"
    end
  end

  def update
    entry = Entry.find(params[:id])
    entry.update_attributes(params[:entry]) # Error checking?
    render :update do |page|
      page.replace_html 'main', :partial => 'show', :locals => {:entry => entry}
      page.replace_html 'diary-tags', :partial => "tags/list"      
    end
  end

  # DELETE /notes/1
  # DELETE /notes/1.xml
  def destroy
    entry = Entry.find(params[:id])
    entry.destroy
    render :update do |page|
      page.replace_html 'main', "Deleted"
      page.replace_html 'diary-tags', :partial => "tags/list"            
    end
  end

end
