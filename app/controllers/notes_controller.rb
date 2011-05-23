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

class NotesController < ApplicationController

  require 'citation_export'

  # GET /notes
  # GET /notes.xml
  def index
    @notes = Note.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @notes }
    end    
  end
  
  # GET /notes/1
  # GET /notes/1.xml
  def show
    note = Note.find(params[:id])
    keys = note.keywords
    add_to_history(note)
    render :update do |page|    
      page.replace_html 'history', :partial => 'rriki/history', :locals => {:selected => "Note:#{note.id}"}
      page.replace_html 'item-div', :partial => 'show', :locals => {:note => note, :divid => 'item-div'}
      page.replace_html 'item-keyword-div', :partial => 'keywords/linked_keywords', 
            :locals => {:keys => keys, :item => note, :divid => 'item-keyword-div'}
      page.call 'display', 'item-body'
    end 
  end

  # GET /notes/new?parent=xx
  # GET /notes/new.xml
  def new
    note = Note.new
    note.date = DateTime.now
    render :update do |page|
      page.replace_html 'item-div', 
          :partial => 'form', 
           :locals => {:note => note,
                       :creating => true,
                       :divid => params[:divid]}      
      page.replace_html 'item-keyword-div', ''
    end 
  end

  # GET /notes/1/edit
  def edit
    note = Note.find(params[:id])
    render :partial => 'form', 
           :locals => {:note => note,
                       :creating => false,
                       :divid => params[:divid]}
  end

  # POST /notes
  # POST /notes.xml
  def create
    note = Note.new(params[:note])
    note.save # Error checking?
    keys = note.keywords
    render :update do |page|    
      page.replace_html 'item-div', :partial => 'show', :locals => {:note => note, :divid => 'item-div'}
      page.replace_html 'item-keyword-div', :partial => 'keywords/linked_keywords', 
            :locals => {:keys => keys, :item => note, :divid => 'item-keyword-div'}
    end
  end

  # PUT /notes/1
  # PUT /notes/1.xml
  def update
    note = Note.find(params[:id])
    note.update_attributes(params[:note]) # Error checking?
    render :update do |page|
      page.replace_html 'item-div', :partial => 'show', :locals => {:note => note, :divid => 'item-div'}
      page.call 'display', 'item-body'  #Needed to run ASCIIMathML  
      #The code below was to update the relevant entry in the middle pane list
      #but it is too kludgy and removed it
      #page<< "if($('title-note#{note.id}')){"
      #page.replace_html "title-note#{note.id}", "<b>#{note.date.strftime('%x')}</b> #{note.title}"
      #page << "}"
    end
  end

  # DELETE /notes/1
  # DELETE /notes/1.xml
  def destroy
    note = Note.find(params[:id])
    note.destroy
    render :update do |page|
      page.replace_html 'item-div', "Deleted"
      page.replace_html 'item-keyword-div', ""
      page.replace_html "div-note#{params[:id]}", "Deleted"
    end
  end
  
  # Expects one input passed through 'params'
  # params[:id]
  def save_citations_as_bibtex
    note = Note.find(params[:id])
    sources = extract_sources_from_note(note)
    send_data BibTeX_export.export_citations(sources), :filename => 'citations.bib'
  end

  # Expects one input passed through 'params'
  # params[:id]
  def save_citations_as_word_xml
    note = Note.find(params[:id])
    sources = extract_sources_from_note(note)
    send_data Word_xml_export.export_citations(sources), :filename => '~//Documents//Microsoft User Data//Sources.xml'
  end

  # Expects one input passed through 'params'
  # params[:id]
  def save_citations_as_RIS
    note = Note.find(params[:id])
    sources = extract_sources_from_note(note)
    send_data RIS_export.export_citations(sources), :filename => 'citations.ris'
  end
  
end
