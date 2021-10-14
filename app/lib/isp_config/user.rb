module IspConfig
	class User < Base
		attr_accessor :user,:template

		include RedisConcern

    def initialize user
      @user = user
    end

		def create(product_id)
			@product = Spree::Product.find_by_id(product_id)
			if user.isp_config_id.blank?
				set_password('isp_config') if get_password('isp_config').blank? 
				response = query({
				    :endpoint => '/json.php?client_add',
				    :method => :GET,
				    :body => user_hash
				    
				})
				if response.code == "ok"
					user.isp_config_id = response.response
					user.save
					{:success=>true, :message=>I18n.t('isp_config.user_created'),response: response}
				else
				  {:success=>false,:message=> I18n.t('isp_config.something_went_wrong',message: response.message),response: response}
				end
			else
				{:success=>true,:message=> I18n.t('isp_config.user_already_exists')}
			end
		end


		def update
			if user.isp_config_id.present?
				response = query({
			    :endpoint => '/json.php?client_update',
			    :method => :GET,
			    :body => user_hash.merge({client_id: user.isp_config_id})
				})
				if  response.code == "ok"
					{:success=>true, :message=>I18n.t('isp_config.user_updated'),response: response}
				else
				  {:success=>false,:message=> I18n.t('isp_config.something_went_wrong',message: response.message),response: response}
				end
			else
				{:success=>true,:message=> I18n.t('isp_config.user_does_not_exists')}
			end
		end


		def attach_template(template_id)
	    if user.isp_config_id.present?
				response = query({
			    :endpoint => '/json.php?client_update',
			    :method => :GET,
			    :body => {client_id: user.isp_config_id,params: {template_master: template_id}}
				})
				
				if  response.code == "ok"
					{:success=>true, :message=>I18n.t('isp_config.template_updated'),response: response}		
				else
				 msg = "Something went wrong. IspConfig Error: #{respponse.message}"
				  {:success=>false,:message=> msg,response: response}
				end
			else
				{:success=>false,:message=>'IspConfig user account does not exists.'}
			end
		end

		def update_password
			if user.isp_config_id.present?
				new_password = Devise.friendly_token.first(8)
				response = query({
			    :endpoint => '/json.php?client_change_password',
			    :method => :GET,
			    :body => {client_id: user.isp_config_id,new_password: new_password}
				})
				if response.code == "ok"
					{:success=>true, :message=>'IspConfig password updated successfully',response: response,new_password: new_password}
				else
					{:success=>false,:message=> I18n.t('isp_config.something_went_wrong',message: response.message),response: response}
				end
			else
				{:success=>false,:message=>'IspConfig user account does not exists.'}
			end
		end 

    def disable_client_login
        if user.isp_config_id.present?
          response = query({
          :endpoint => '/json.php?client_update',
          :method => :POST,
          :body => { client_id: user.isp_config_id,params: { canceled: 'y' }} })

          if response.code == "ok"
              {:success=>true, :message=>'IspConfig account canceled successfully',response: response}
          else
            {:success=>false,:message=> I18n.t('isp_config.something_went_wrong',message: response.message),response: response}
          end
        else
          {:success=>false,:message=>'IspConfig user account does not exists.'}
        end
    end

     def enable_client_login
        if user.isp_config_id.present?
          response = query({
          :endpoint => '/json.php?client_update',
          :method => :POST,
          :body => { client_id: user.isp_config_id,params: { canceled: 'n' }} })

          if response.code == "ok"
              {:success=>true, :message=>'IspConfig account enabled successfully',response: response}
          else
            {:success=>false,:message=> I18n.t('isp_config.something_went_wrong',message: response.message),response: response}
          end
        else
          {:success=>false,:message=>'IspConfig user account does not exists.'}
        end
    end

   	#Package API interface for the  user/Reseller
   	def template
   		@template ||= IspConfig::Template.new(user)
   	end

		private

		def user_hash
			template = @product.isp_config_limit || @product.build_isp_config_limit
			address = user.addresses.first
			{
				reseller_id: user.reseller_id,
			    "params": {
			    company_name: user.company_name,
			    contact_name: user.full_name.present? ? user.full_name : 'Empty' ,
			    customer_no:  user.id,
			    "vat_id": "",
			    street: address&.address1,
			    zip: address&.zipcode,
			    city: address&.city,
			    state: address&.state&.name,
			    country: address&.country&.iso,
			    telephone: "",
			    mobile: address&.phone,
			    "fax": "",
			    email: user.email,
			    "internet": "",
			    "icq": "",
			    notes: @product&.description,
			    default_mailserver: template.default_mailserver,
			    limit_maildomain: template.limit_maildomain,
			    limit_mailbox: template&.limit_mailbox,
			    limit_mailalias: template&.limit_mailalias,
			    limit_mailaliasdomain: template&.limit_mailaliasdomain,
			    limit_mailforward: template.limit_mailforward,
			    limit_mailcatchall: template.limit_mailcatchall,
			    limit_mailrouting: template.limit_mailrouting,
			    limit_mailfilter: template.limit_mailfilter,
			    limit_fetchmail: template.limit_fetchmail,
			    limit_mailquota: template.limit_mailquota,
			    limit_spamfilter_wblist: template.limit_spamfilter_wblist,
			    limit_spamfilter_user: template.limit_spamfilter_user,
			    limit_spamfilter_policy: template.limit_spamfilter_policy,
			    default_webserver: template.default_webserver || 1,
			    limit_web_ip: template.limit_web_ip,
			    limit_web_domain: template.limit_web_domain,
			    limit_web_quota: template.limit_web_quota,
			    web_php_options: "no,fast-cgi,cgi,mod,suphp",
			    limit_web_subdomain: template.limit_web_subdomain,
			    limit_web_aliasdomain: template.limit_web_aliasdomain,
			    limit_ftp_user: template.limit_ftp_user,
			    limit_shell_user: template.limit_shell_user,
			    ssh_chroot: "no,jailkit,ssh-chroot",
			    limit_webdav_user: template.limit_webdav_user,
			    default_dnsserver: 1,
			    limit_dns_zone: template.limit_dns_zone,
			    limit_dns_slave_zone: template.limit_dns_slave_zone,
			    limit_dns_record: template.limit_dns_record,
			    default_dbserver: template.default_dbserver,
			    limit_database: template.limit_database,
			    limit_cron: template.limit_cron,
			    limit_cron_type: template.limit_cron_type,
			    limit_cron_frequency: template.limit_cron_frequency,
			    limit_traffic_quota: template.limit_traffic_quota,
			    limit_client: get_user_limits(template),
			    parent_client_id: 0,
			    username: get_username,
			    password:  get_password('isp_config'),
			    "language": "en",
			    "usertheme": "default",
			    template_master: get_master_template_id,
			    "template_additional": "",
			    "created_at": 0,
			    reseller: user.store_admin? ? 1 : 0
            }
        }
		end

		def get_user_limits(template)
			user.store_admin? ? template.limit_client : 0
		end

		def get_master_template_id
			0
		end

	end
end



