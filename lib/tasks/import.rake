namespace :import do
  desc "Generate invoice for each user subscriptions"
  task import_user: :environment do
   
    # Current tenant is set for all code in this block

      file = Roo::Spreadsheet.open('./users.xlsx')

      ImportManager::UserImporter.new(file).call

 

  end
end