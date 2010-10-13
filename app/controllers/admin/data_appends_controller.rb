class Admin::DataAppendsController < ApplicationController
 layout 'admin'
  
  def index
    @data_appends =  DataAppend.all
  end

  def show
    @data_append = DataAppend.find(params[:id])
  end

 
  def new
    @data_append =  DataAppend.new
  end

 
  def edit
    @data_append =  DataAppend.find(params[:id])
  end


  def create
    @data_append = DataAppend.new(params[:data_append])
    if @data_append.save
      redirect_to(:back, :notice => 'DataAppend was successfully created.') 
    end  
 
  end

 
  def update
    @data_append = Admin::DataAppend.find(params[:id])

    respond_to do |format|
      if @data_append.update_attributes(params[:data_append])
        format.html { redirect_to(@data_append, :notice => 'Admin::DataAppend was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @data_append.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /admin_data_appends/1
  # DELETE /admin_data_appends/1.xml
  def destroy
    @data_append = Admin::DataAppend.find(params[:id])
    @data_append.destroy

    respond_to do |format|
      format.html { redirect_to(admin_data_appends_url) }
      format.xml  { head :ok }
    end
  end
end
