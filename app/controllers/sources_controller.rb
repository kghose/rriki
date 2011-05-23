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

class SourcesController < ApplicationController
  # GET /sources
  # GET /sources.xml
  def index
    @sources = Source.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @sources }
    end
  end

  # GET /sources/1
  # GET /sources/1.xml
  def show
    source = Source.find(params[:id])
    keys = source.keywords
    add_to_history(source)    
    render :update do |page|
      page.replace_html 'history', :partial => 'rriki/history', :locals => {:selected => "Source:#{source.id}"}      
      page.replace_html 'item-div', :partial => 'show', :locals => {:source => source, :divid => 'item-div'}
      page.call 'display', 'item-body'
      page.replace_html 'item-keyword-div', :partial => 'keywords/linked_keywords', 
            :locals => {:keys => keys, :item => source, :divid => 'item-keyword-div'}
    end
  end

  # GET /sources/new
  # GET /sources/new.xml
  def new
    source = Source.new
    keys = []
    render :update do |page|    
      page.replace_html 'item-div', 
                 :partial => 'form', 
                 :locals => {:source => source,
                             :creating => true, 
                             :divid => 'item-div'}
      page.replace_html 'item-keyword-div', :partial => 'keywords/linked_keywords', 
            :locals => {:keys => keys, :item => source, :divid => 'item-keyword-div'}
    end    
  end

  def new_from_pmid
    source = Source.get_source_from_pmid(params[:pmid]['value'])
    keys = []
    render :update do |page|    
      page.replace_html 'item-div', 
                 :partial => 'form', 
                 :locals => {:source => source,
                             :creating => true, 
                             :divid => 'item-div'}
      page.replace_html 'item-keyword-div', :partial => 'keywords/linked_keywords', 
            :locals => {:keys => keys, :item => source, :divid => 'item-keyword-div'}
    end    
  end

  # GET /sources/1/edit
  def edit
    source = Source.find(params[:id])
    render :partial => 'form', 
           :locals => {:source => source,
                       :creating => false,
                       :divid => params[:divid]}
  end

  # POST /sources
  # POST /sources.xml
  def create
    @source = Source.new(params[:source])

    respond_to do |format|
      if @source.save
        flash[:notice] = 'Source was successfully created.'
        format.html { redirect_to(@source) }
        format.xml  { render :xml => @source, :status => :created, :location => @source }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @source.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /sources/1
  # PUT /sources/1.xml
  def update
    source = Source.find(params[:id])
    source.update_attributes(params[:source]) # Error checking?
    render :update do |page|
      page.replace_html 'item-div', :partial => 'show', :locals => {:source => source, :divid => 'item-div'}
      page.call 'display', 'item-body'
      page<< "if($('title-source#{source.id}')){"
      page.replace_html "title-source#{source.id}", "(<b>#{source.citekey}</b>) #{source.title}"
      page << "}"
    end
  end

  # DELETE /sources/1
  # DELETE /sources/1.xml
  def delete
    source = Source.find(params[:id])
    source.destroy
    render :update do |page|
      page.replace_html 'item-div', 'Deleted'
    end
  end
  
#  def send_pdf
#    if RrikiParam.exists?(:key => 'paper library location')
#      source = Source.find(params[:id])
#      pdf_dir = RrikiParam.find_by_key('paper library location')
#      pdf_file = source.citekey + '.pdf'
#      #x-sendfile from http://www.therailsway.com/2009/2/22/file-downloads-done-right
#      send_file pdf_dir + '/' + pdf_file, :type=>"application/pdf", :x_sendfile=>true
#    else
#      render :text => 'Paper library location not set. Please set it'
#    end
#  end
end
