namespace :site_builder_ftps do
  desc "Update Site Builder Ftp Users"
  task update: :environment do
    UserDomain.all.collect{|x|x if x.linux?}.compact.each do |user_domain|
      begin
        response = user_domain.user.isp_config.ftp_user.all
        site_builder_ftps = response[:response].response.collect{|x| x if x[:username].include?"site_builder"}.compact
        next if site_builder_ftps.nil?
        site_builder_ftps.each do |site_builder_ftp|
          website = user_domain.user.isp_config.website.find(site_builder_ftp[:parent_domain_id])
          next if website[:response].response.nil?
          userdomain = UserDomain.where(domain: website[:response].response[:domain]).last
          next if userdomain.nil? 
          ftp_user = UserFtpUser.find_or_create_by({username: site_builder_ftp[:username]})
          ftp_user.update({
                user_domain_id: userdomain.id,
                remote_ftp_user_id: site_builder_ftp[:ftp_user_id],
                dir: site_builder_ftp[:dir],
                active: site_builder_ftp[:active] == 'y' ? 1 : 0
              })
              puts "Ftp User from panel updated. #{userdomain.id} / #{site_builder_ftp[:username]}"
        end
      rescue Exception => e
        Rails.logger.error { "something went wrong. #{e.message}"}
      end
    end

    UserDomain.all.collect{|x|x if x.windows?}.compact.each do |user_domain|
      begin
        response = user_domain.user.solid_cp.ftp_account.all
        res = response.body[:get_ftp_accounts_response][:get_ftp_accounts_result][:ftp_account]
        res = [res] if res.is_a?(Hash)
        site_builder_ftps = res.collect{|x| x if x[:name].include?"site_builder"}.compact
        next if site_builder_ftps.nil?
        site_builder_ftps.each do |site_builder_ftp|
          userdomain = UserDomain.where(domain: site_builder_ftp[:folder].split('\\')[1]).last
          next if userdomain.nil? 
          ftp_user = UserFtpUser.find_or_create_by({username: site_builder_ftp[:name]})
          ftp_user.update({
                user_domain_id: userdomain.id,
                remote_ftp_user_id: site_builder_ftp[:id],
                dir: site_builder_ftp[:folder],
                active: 1
              })
              puts "Ftp Account from panel updated.#{userdomain.id} / #{site_builder_ftp[:name]}"
        end
      rescue Exception => e
        Rails.logger.error { "something went wrong. #{e.message}"}
      end
    end
    
  end
end