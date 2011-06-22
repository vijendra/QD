set :output, {:error => "/home/rails/d2leads/log/whenever_error.txt", :standard => "/home/rails/d2leads/log/whenever_sucess.txt" }


every 2.minutes do
  runner "DncNumber.send_for_dnc('weekly')"
end
every 15.days do
  runner "DncNumber.send_for_dnc('15 days')"
end
every 30.days do
  runner "DncNumber.send_for_dnc('monthly')"
end

