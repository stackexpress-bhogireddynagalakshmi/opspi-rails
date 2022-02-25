# frozen_string_literal: true

module SolidCp
  class User < Base
    client wsdl: SOAP_USER_WSDL, endpoint: SOAP_USER_WSDL, log: SolidCp::Config.log
    global :read_timeout, SolidCp::Config.timeout
    global :open_timeout, SolidCp::Config.timeout
    global :basic_auth, SolidCp::Config.username, SolidCp::Config.password

    include RedisConcern

    attr_reader :user, :package

    def initialize(user)
      @user = user
    end

    operations :user_exists, :get_user_by_id, :get_user_by_username, :get_users, :add_user_v_lan, :delete_user_v_lan, :get_raw_users,
               :get_users_paged, :get_users_paged_recursive, :get_users_summary, :get_user_domains_paged, :get_raw_user_peers, :get_user_peers,
               :get_user_parents, :add_user, :add_user_literal, :update_user_task, :update_user_task_asynchronously, :update_user, :update_user_literal,
               :delete_user, :change_user_password, :change_user_status, :get_user_settings, :update_user_settings

    def get_user_by_id
      super(message: { user_id: user.solid_cp_id })
    end

    def get_user_by_username
      super(message: { username: user.login })
    end

    # http://solidcpent.myhsphere.biz:9002/esUsers.asmx?op=ChangeUserStatus
    # Active or Suspended or Cancelled or Pending

    def change_user_status(status)
      return nil unless user.solid_cp_id.present?

      response = super(message: { user_id: user.solid_cp_id, status: status })
      if response.success?
        { success: true, message: 'SolidCP User status changed successfully', response: response }
      else
        { success: false, message: 'Something went wrong.', response: response }
      end
    end

    def delete_user
      return nil unless user.solid_cp_id.present?

      super(message: { user_id: user.solid_cp_id })
    end

    def change_user_password
      new_password = Devise.friendly_token.first(8)
      response = super(message: { user_id: user.solid_cp_id, password: new_password })
      if response.success?
        { success: true, message: 'SolidCP User created successfully', response: response, new_password: new_password }
      else
        { success: false, message: 'Something went wrong.', response: response }
      end
    end

    # Creates User on SolidCP server
    # Role can  be Administrator or Reseller or User or ResellerCSR or PlatformCSR or ResellerHelpdesk or PlatformHelpdesk
    # For Administrator Role id 1
    # for Reseller Role id 2
    # For User Role id 3
    # User can be created under any user or reseller so the Owner Id is parent of the current user beimng created

    def add_user(user_type = 'User', role_id = 3)
      if user.solid_cp_id.blank?
        set_password if get_password.blank?
        response = super(message: {
          user: {
            "RoleId" => role_id,
            "Role" => user_type,
            "Status" => 'Active',
            "LoginStatusId" => '0',
            "LoginStatus" => 'Enabled',
            "IsDemo" => false,
            "OwnerId" => user.owner_id,
            "LastName" => user.last_name,
            "Username" => user.login,
            "FirstName" => user.first_name,
            "Email" => user.email,
            "CompanyName" => user.company_name,
            "HtmlMail" => false
          }, password: get_password
        })

        if response.success? && response.body[:add_user_response][:add_user_result].to_i.positive?
          user.solid_cp_id = response.body[:add_user_response][:add_user_result]
          user.save
          { success: true, message: 'SolidCP User created successfully', response: response }
        else
          msg = "Something went wrong while creating user account. SolidCP ErrorCode: #{response.body[:add_user_response][:add_user_result]}"
          { success: false, message: msg, response: response }

        end
      else
        { success: true, message: "SolidCP account already exists for this user. #{user.email}" }
      end
    end

    # this action pulls the User Lis form SolidCP panel
    # By default It will pull all the users from SolidCP
    # if we provide the owner_id then it will pulls only those user created under that owner

    def self.get_users(owner_id = 1)
      response = super(message: { owner_id: owner_id, recursive: true })
      user_arr = response.body[:get_users_response][:get_users_result][:user_info]
      users = user_arr.collect { |user| OpenStruct.new(user) }
      { success: true, users: users }
    end

    # This action is used internally to sync the no existing users on SolidCP
    # It will create non existing users of opspi on solidCP server

    def self.sync_users(users)
      response_hash = []
      users.each do |user|
        response_hash << user.solid_cp.add_user('Reseller')
      end
      response_hash
    end

    # Package API interface for the  user/Reseller
    def package
      @package ||= SolidCp::Package.new(user)
    end

    # HostingPlan API interface for the  user/Reseller
    def plan(product)
      @plan ||= SolidCp::Plan.new(user, product)
    end

    # Helper  method to render full_name
    def full_name
      "#{user.first_name} #{user.last_name}"
    end
  end
end

# SolidCp::User.client.build_request(:add_user).body
