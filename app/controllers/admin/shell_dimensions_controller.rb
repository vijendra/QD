class Admin::ShellDimensionsController < ApplicationController
  def new
    @dealer = Dealer.find(params[:dealer_id])
    @shell = params[:t]
    @shell_dimension = ShellDimension.new
  end


  def create
    @dealer = Dealer.find(params[:dealer_id])
    template = params[:shell_dimension][:template]
    #@shell_dimension = ShellDimension.new(params[:shell_dimension])
    params[:values].each_pair{|k, v| ShellDimension.create( :dealer_id => params[:dealer_id],
                                                            :template => template,
                                                            :variable => k,
                                                            :value =>  v
                                                           )
    }
    flash[:notice]= 'Shell dimensions are successfully saved.'
    redirect_to admin_dealer_print_data_path(:dealer_id => @dealer.id)
  end

  def shell_matrix
    respond_to do |format|
                   format.html
                   format.pdf {
                      width ||= (params[:width_inch].to_f * 72 || params[:width_mm].to_i * 2.8334 || params[:width_points].to_i)
                      height ||= (params[:height_inch].to_f * 72 || params[:height_mm].to_i * 2.8334 || params[:height_points].to_i)
      #{height}"
                      options = { :left_margin => 0, :right_margin => 0, :top_margin => 0, :bottom_margin => 0, :page_size => [width, height] }
                      prawnto :inline => true, :prawn => options, :page_orientation => :portrait, :filename => 'shell_layout.pdf'
                      render :layout => false
                     }
                   end
  end
end
