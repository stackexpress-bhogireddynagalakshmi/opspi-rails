# frozen_string_literal: true

module SolidCp
  class FtpAccount < Base
    attr_reader :user

    client wsdl: SOAP_FTP_WSDL, endpoint: SOAP_FTP_WSDL, log: SolidCp::Config.log
    global :read_timeout, SolidCp::Config.timeout
    global :open_timeout, SolidCp::Config.timeout
    global :basic_auth, SolidCp::Config.username, SolidCp::Config.password

    operations :get_ftp_sites,
               :get_raw_ftp_accounts_paged,
               :get_ftp_accounts,
               :get_ftp_account,
               :add_ftp_account,
               :update_ftp_account,
               :delete_ftp_account

    def initialize(user)
      @user = user
    end

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

    def add_ftp_account(params)
      response = super(message: {
        item: {
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
        { success: true, message: 'Ftp Account created successfully', response: response }
      else
        { success: false, message: "Something went wrong. #{error[:msg]}.", response: response }
      end
    rescue => e
      { success: false, message: "Something went wrong. #{e.message}.", response: response }
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

      if response.success?
        { success: true, message: 'Ftp User updated successfully', response: response }
      else
        { success: false, message: "Something went wrong. #{error[:msg]}.", response: response }
      end
     rescue => e
      { success: false, message: "Something went wrong. #{e.message}.", response: response }
    end
    alias update update_ftp_account

    def delete_ftp_account(id)
      response = super(message: { itemId: id })

      if response.success?
        { success: true, message: 'Ftp User deleted successfully', response: response }
      else
        { success: false, message: 'Something went wrong. Please try again.', response: response }
      end
    end
    alias destroy delete_ftp_account
  end
end
