class Admin::ShellDimensionsController < ApplicationController
  require 'fileutils'
  def new
    @dealer = Dealer.find(params[:dealer_id])
    @shell = params[:t]
    @partial = "template#{params[:t]}"
    @shell_dimension = ShellDimension.new
    @positions = {}
    unless @dealer.administrator.blank?
     dimensions = @dealer.administrator.shell_dimensions.find(:all, :conditions => ["template = ? ", params[:t] ])   
     dimensions.map{ |rec| @positions[rec.variable]= rec.value.to_f } unless dimensions.blank?
    end

  end


  def create
    @dealer = Dealer.find(params[:dealer_id])
    template = params[:shell_dimension][:template]
    if current_user.has_role?('super_admin')
       administrator_id = @dealer.administrator_id
    elsif current_user.has_role?('admin')
      administrator_id = current_user.id
    end
    
    if administrator_id
      ShellDimension.find(:all,:conditions =>["administrator_id = ? and template = ? ",administrator_id ,template ]).map{ |ob| ob.destroy }
      params[:values].each_pair{|k, v| ShellDimension.create( :administrator_id => administrator_id,
                                                              :template => template,
                                                              :variable => k,
                                                              :value =>  v
                                                            )
                     }
      #made changes here               
      unless params[:image].blank?
        image = ShellImage.find(:first,:conditions =>["administrator_id = ? and template = ? ",administrator_id ,template ]) 
        FileUtils.rm_r "#{RAILS_ROOT}/public/shell_images/#{image.id}"
        image.destroy
        ShellImage.create(:administrator_id => administrator_id ,:template => template ,:shell_image => params[:image] ) 
      end
      
      flash[:notice] = 'Shell dimensions are successfully saved.'
    else 
      flash[:notice] = 'Shell dimensions not saved Because dealer not assigned to administrator'
    end  
    redirect_to new_admin_dealer_shell_dimension_path(:dealer_id => @dealer.id, :t => template)
  end


  def shell_matrix
    respond_to do |format|
                   format.html 

                   format.pdf {
                      width ||= (params[:width_inch].to_f * 72 || params[:width_mm].to_i * 2.8334 || params[:width_points].to_i || params[:width_cm].to_i)
                      height ||= (params[:height_inch].to_f * 72 || params[:height_mm].to_i * 2.8334 || params[:height_points].to_i || params[:height_cm].to_i)
                      @image = params[:pdf_image]

                      options = { :left_margin => 0, :right_margin => 0, :top_margin => 0, :bottom_margin => 0, :page_size => [width, height] }
                      prawnto :inline => true, :prawn => options, :page_orientation => :portrait, :filename => 'shell_layout.pdf'
                      render :layout => false
                     }
                   end
  end
end
