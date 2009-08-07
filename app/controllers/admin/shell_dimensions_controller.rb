class Admin::ShellDimensionsController < ApplicationController
  def new
    @dealer = Dealer.find(params[:dealer_id])
    @shell = params[:t]
    @shell_dimension = ShellDimension.new
  end


  def create

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
