module SolidCp

	class User < Base

		extend Savon::Model
		 SOAP_WSDL = "http://jodocp.infiops.com:9002/esUsers.asmx?wsdl"

		attr_reader :user

	    def initialize user
	      @user = user
	    end

	    #delete_namespace_attributes: true
		client wsdl: SOAP_WSDL, endpoint: SOAP_WSDL,log: SolidCp::Config.log
		global :open_timeout, SolidCp::Config.timeout
  		global :basic_auth, SolidCp::Config.username, SolidCp::Config.password


		operations :user_exists, :get_user_by_id,:get_user_by_username, :get_users, :add_user_v_lan, :delete_user_v_lan, :get_raw_users,
		 		   :get_users_paged, :get_users_paged_recursive, :get_users_summary, :get_user_domains_paged, :get_raw_user_peers, :get_user_peers,
		 		   :get_user_parents, :add_user, :add_user_literal, :update_user_task, :update_user_task_asynchronously, :update_user, :update_user_literal,
		   		   :delete_user, :change_user_password, :change_user_status, :get_user_settings, :update_user_settings



	    def get_user_by_id
	    	super(message: { user_id: user.user.solid_cp_id })
	    end


	    def get_user_by_username
	   		super(message: { username: user.login })
	    end

	    def change_user_status
	      super(message: { user_id: user.solid_cp_id,status: 'Active'})
	    end

	    def delete_user
	    	super(message: { user_id: user.user.solid_cp_id})
	    end

	    def change_user_password
	    	super(message: { user_id: user.user.solid_cp_id,password: user.password})
	    end

	    def add_user
	    	if user.solid_cp_id.blank?

	    		if user.solid_cp_password.blank?
	    			user.solid_cp_password = SolidCp::Misc.password_generator
	    			user.save 
	    		end
	    		
			   	response = super(message: { 
			   		user: {
			   			"RoleId" => 3,
				   		"Role" => 'User',
				   		"Status"=> 'Active',
				   		"LoginStatusId"=> '0',
				   		"LoginStatus"=> 'Enabled',
				   		"IsDemo"=> true,
				   		"OwnerId" =>'1',
				   		"LastName"=> user.last_name,
				   		"Username" =>user.login,
				   		"FirstName" =>user.first_name,
				   		"Email"=> user.email,
				   		"CompanyName" => Account.find(user.account_id).orgainization_name,
				   	    "HtmlMail"=> false,

			   		},password: user.solid_cp_password
			   	 })

			   	if response.success?
			   		user.solid_cp_id = response.body[:add_user_response][:add_user_result]
			   		user.save
			   		{:success=>true, :message=>'SolidCP User created successfully',response: response}
			   	else
			   		{:success=>false,:message=> "Something went wrong. Please try again.",response: response}
			   	end
			else
				{:success=>false,:message=> "SolidCP user alread exists for this user."}
			end
	   end
  	end
end

#SolidCp::User.client.build_request(:add_user).body
