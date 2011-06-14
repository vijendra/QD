module Admin::ShellDimensionsHelper

  def pdf_size(dim, temp)
    case dim
    when 'width'
      return (temp.to_i == 4)? '1267' : '612'
    when 'height'
      return (temp.to_i == 4)? '807' : '1008'
    end
  end
end

