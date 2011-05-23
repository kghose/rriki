class RrikiParamsController < ApplicationController
  # GET /rriki_params
  # GET /rriki_params.xml
  def index
    @rriki_params = RrikiParam.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @rriki_params }
    end
  end

  # GET /rriki_params/1
  # GET /rriki_params/1.xml
  def show
    @rriki_param = RrikiParam.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @rriki_param }
    end
  end

  # GET /rriki_params/new
  # GET /rriki_params/new.xml
  def new
    @rriki_param = RrikiParam.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @rriki_param }
    end
  end

  # GET /rriki_params/1/edit
  def edit
    @rriki_param = RrikiParam.find(params[:id])
  end

  # POST /rriki_params
  # POST /rriki_params.xml
  def create
    @rriki_param = RrikiParam.new(params[:rriki_param])

    respond_to do |format|
      if @rriki_param.save
        flash[:notice] = 'RrikiParam was successfully created.'
        format.html { redirect_to(@rriki_param) }
        format.xml  { render :xml => @rriki_param, :status => :created, :location => @rriki_param }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @rriki_param.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /rriki_params/1
  # PUT /rriki_params/1.xml
  def update
    @rriki_param = RrikiParam.find(params[:id])

    respond_to do |format|
      if @rriki_param.update_attributes(params[:rriki_param])
        flash[:notice] = 'RrikiParams was successfully updated.'
        format.html { redirect_to(@rriki_param) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @rriki_param.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /rriki_params/1
  # DELETE /rriki_params/1.xml
  def destroy
    @rriki_param = RrikiParam.find(params[:id])
    @rriki_param.destroy

    respond_to do |format|
      format.html { redirect_to(rriki_param_url) }
      format.xml  { head :ok }
    end
  end
end
