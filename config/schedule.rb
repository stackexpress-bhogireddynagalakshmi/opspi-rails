# Ensure required enviroment variables are provided
ENV.each { |k, v| env(k, v) }

job_type :opspi_cron, "cd :path && :environment_variable=:environment :bundle_command rake :task"

#every 1 am 
every '0 1 * * *' do
  opspi_cron "invoices:generate_invoices"
end

#every 2 am 
every '0 2 * * *' do
  opspi_cron 'invoices:auto_payment'
end

#every 3 am 
every '0 3 * * *' do
  opspi_cron 'invoices:disable_control_panel'
end

#every 4 am 
every '0 4 * * *' do
  opspi_cron 'invoices:enable_control_panel'
end

every '0 1 * * *' do
  opspi_cron "quota_usages:update_quota_usage"
end


