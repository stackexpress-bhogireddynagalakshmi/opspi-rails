# frozen_string_literal: true

module SolidCp
  class FtpAccount < Base
    attr_reader :user

    def initialize(user)
      @user = user

      set_configurations(user, SOAP_FTP_WSDL)
    end

    operations :get_ftp_sites,
               :get_raw_ftp_accounts_paged,
               :get_ftp_accounts,
               :get_ftp_account,
               :add_ftp_account,
               :update_ftp_account,
               :delete_ftp_account

   

    def get_ftp_accounts
      response = super(message: { package_id: user.packages.first.try(:solid_cp_package_id) })
    end
    alias all get_ftp_accounts

    def get_ftp_account(id)
      response = super(message: { itemId: id })
    end
    alias find get_ftp_account

    # <item>
    #   <CanRead>boolean</CanRead>
    #   <CanWrite>boolean</CanWrite>
    #   <Folder>string</Folder>
    #   <Password>string</Password>
    #   <Enabled>boolean</Enabled>
    # </item>

    def add_ftp_account(params, opts={})
      response = super(message: {
          item: {
            "PackageId" => user.packages.first.try(:solid_cp_package_id),
            "CanRead" => params[:can_read] || true,
            "CanWrite" => params[:can_write] || true,
            "Folder" => params[:folder],
            "Name" => params[:username],
            "Password" => params[:password],
            "Enabled" => params[:enabled] || true
          }
        }
      )
      code  = response.body["#{__method__}_response".to_sym]["#{__method__}_result".to_sym].to_i
      error = SolidCp::ErrorCodes.get_by_code(code)
      if response.success? && code > 0
        user_domain = opts[:user_domain]
        user_domain.user_ftp_users.create(ftp_user_params(params).merge({ remote_ftp_user_id: code })) if user_domain.present?
        { success: true, message: 'Ftp Account created successfully', response: response }
      else
        { success: false, message: error[:msg], response: response }
      end
    rescue => e
      { success: false, message: error_message(e.message), response: response }
    end
    alias create add_ftp_account

    def update_ftp_account(id, params)
      response = super(message: {

        item: {
          "itemId" => id,
          "PackageId" => user.packages.first.try(:solid_cp_package_id),
          "CanRead" => params[:can_read],
          "CanWrite" => params[:can_write],
          "Folder" => params[:folder],
          "Name" => params[:username],
          "Password" => params[:password],
          "Enabled" => true
        }
      }
      )
      code  = response.body["#{__method__}_response".to_sym]["#{__method__}_result".to_sym].to_i
      error = SolidCp::ErrorCodes.get_by_code(code)

      if response.success? && code > 0
        { success: true, message: 'Ftp User updated successfully', response: response }
      else
        { success: false, message:  error[:msg], response: response }
      end
     rescue => e
      { success: false, message: e.message, response: response }
    end
    alias update update_ftp_account

    def delete_ftp_account(id)
      ftp_user = UserFtpUser.find_by_id(id)

      response = super(message: { itemId: ftp_user.remote_ftp_user_id })

      if response.success?
        ftp_user.try(:destroy)

        { success: true, message: 'Ftp User deleted successfully', response: response }
      else
        { success: false, message: 'Something went wrong. Please try again.', response: response }
      end
    end
    alias destroy delete_ftp_account

    def error_message(error)
      if error.include?("password policy requirements")
        error = I18n.t("windows.ftp_account.password_hint_message")
      else
        error
      end
    end

    def ftp_user_params(params)
      {
        username: params[:username],
        dir: params[:folder],
        active: true
      }

    end
  end
end
