namespace :user_domains do
  desc "Update User Domains"
  task update: :environment do
    HostedZone.all.each do |hosted_zone|
      puts "Updating #{hosted_zone.name}"

      Rails.logger.info {
        "Updating #{hosted_zone.name}"
      }
      if hosted_zone.name.blank?
        begin
          response = hosted_zone.user.isp_config.hosted_zone.get_zone(hosted_zone.isp_config_host_zone_id)
          name = response[:response].response["origin"]
          domain_name = name[-1] == "." ? name[0..-2] : name
          if domain_name.present?
            hosted_zone.update({name: domain_name})

            puts "user_domain from from panel updated. #{domain_name}"
          end
        rescue Exception => e
          Rails.logger.error { "something went wrong. #{e.message}"}
        end
      end
      hosted_zone.reload
      
      next if hosted_zone.name.blank?

      user_domain = UserDomain.find_or_create_by({domain: hosted_zone.name})
      user_domain.update({
        user_id: hosted_zone.user_id
      })

      hosted_zone.update({user_domain_id: user_domain.id})
    end
  end
end