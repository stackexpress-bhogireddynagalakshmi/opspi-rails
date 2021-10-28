#every 1 am 
every '0 1 * * *' do
  rake 'invoices:generate_invoices'
end

every '0 2 * * *' do
  rake 'invoices:auto_payment'
end

every '0 3 * * *' do
  rake 'invoices:disable_control_panel'
end

every '0 4 * * *' do
  rake 'invoices:enable_control_panel'
end



