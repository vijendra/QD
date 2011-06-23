set :output, {:error => "/home/rails/d2leads/log/whenever_error.txt", :standard => "/home/rails/d2leads/log/whenever_sucess.txt" }


every :sunday, :at => '12pm' do
  runner "DncNumber.send_dnc_in_week"
end
every 15.days do
  runner "DncNumber.send_dnc_twice_in_month"
end
every 30.days do
  runner "DncNumber.send_dnc_in_month"
end

