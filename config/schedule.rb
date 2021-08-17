
#every 1 am 

every '0 1 * * *' do
  rake 'invoices:generate_invoices'
end


          