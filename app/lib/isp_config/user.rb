module IspConfig
	class User < Base
		attr_accessor :user,:template

		include RedisConcern


	    def initialize user
	      @user = user
	    end

		def create
			puts "Adding Client"
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
					{:success=>true, :message=>'IspConfig user account created successfully',response: response}
				else
				 msg = "Something went wrong while creating user account. IspConfig Error: #{response.message}"
				   {:success=>false,:message=> msg,response: response}
				end
			else
				{:success=>true,:message=> "IspConfig user account already exists for this user." }
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
					{:success=>true, :message=>'IspConfig user account updated successfully',response: response}
					
				else
				 msg = "Something went wrong while creating user account. IspConfig Error: #{respponse.message}"
				   		{:success=>false,:message=> msg,response: response}
				end
			else
				{:success=>false,:message=>'IspConfig user account does not exists.'}
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
					{:success=>true, :message=>'IspConfig user master template updated successfully',response: response}
					
				else
				 msg = "Something went wrong. IspConfig Error: #{respponse.message}"
				   		{:success=>false,:message=> msg,response: response}
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
			address = user.addresses.first
			{
				reseller_id: user.reseller_id,
			    "params": {
			    company_name: user.company_name,
			    contact_name: user.full_name.present? ? user.full_name : 'Empty' ,
			    "customer_no": user.id,
			    "vat_id": "",
			    "street": address&.address1,
			    "zip": address&.zipcode,
			    "city": address&.city,
			    "state": address&.state&.name,
			    "country": address&.country&.iso,
			    "telephone": "123456789",
			    "mobile": address&.phone,
			    "fax": "546718293",
			     email: user.email,
			    "internet": "",
			    "icq": "111111111",
			    "notes": "awesome",
			    "default_mailserver": 1,
			    "limit_maildomain": -1,
			    "limit_mailbox": -1,
			    "limit_mailalias": -1,
			    "limit_mailaliasdomain": -1,
			    "limit_mailforward": -1,
			    "limit_mailcatchall": -1,
			    "limit_mailrouting": 0,
			    "limit_mailfilter": -1,
			    "limit_fetchmail": -1,
			    "limit_mailquota": -1,
			    "limit_spamfilter_wblist": 0,
			    "limit_spamfilter_user": 0,
			    "limit_spamfilter_policy": 1,
			    "default_webserver": 1,
			    "limit_web_ip": "",
			    "limit_web_domain": -1,
			    "limit_web_quota": -1,
			    "web_php_options": "no,fast-cgi,cgi,mod,suphp",
			    "limit_web_subdomain": -1,
			    "limit_web_aliasdomain": -1,
			    "limit_ftp_user": -1,
			    "limit_shell_user": 0,
			    "ssh_chroot": "no,jailkit,ssh-chroot",
			    "limit_webdav_user": 0,
			    "default_dnsserver": 1,
			    "limit_dns_zone": -1,
			    "limit_dns_slave_zone": -1,
			    "limit_dns_record": -1,
			    "default_dbserver": 1,
			    "limit_database": -1,
			    "limit_cron": 0,
			    "limit_cron_type": "url",
			    "limit_cron_frequency": 5,
			    "limit_traffic_quota": -1,
			     limit_client: get_user_limits,
			    "parent_client_id": 0,
			     username: get_username,
			     password:  get_password('isp_config'),
			    "language": "en",
			    "usertheme": "default",
			    "template_master": get_master_template_id,
			    "template_additional": "",
			    "created_at": 0,
			    reseller: user.store_admin? ? 1 : 0
			   
            }
        }
		end

		def get_user_limits
			user.store_admin? ? 20 : 0
		end

		def get_master_template_id
			0
		end
	end
end