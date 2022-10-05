# frozen_string_literal: true

module SolidCp
  class Backup < Base
    attr_reader :user

    def initialize(user)
      @user = user

      set_configurations(user, SOAP_BACKUP_WSDL)
    end

    operations :get_backup_content_summary,
               :backup,
               :restore
           


      # <async>boolean</async>
      # <taskId>string</taskId>
      # <userId>int</userId>
      # <packageId>int</packageId>
      # <serviceId>int</serviceId>
      # <serverId>int</serverId>
      # <backupFileName>string</backupFileName>
      # <storePackageId>int</storePackageId>
      # <storePackageFolder>string</storePackageFolder>
      # <storeServerFolder>string</storeServerFolder>
      # <deleteTempBackup>boolean</deleteTempBackup>
  
    def backup(id)
      user_website = UserWebsite.find(id)
      response = super(message: { 
        
        async: false,
        # taskId: "SCHEDULE_TASK_BACKUP",
        userId: user.solid_cp_id,
        PackageId: user.packages.first.try(:solid_cp_package_id),
        #serviceId: "",
        storeServerFolder: "\\backup\\",
        backupFileName: "HostingSpace-#{user.packages.first.package_name}-#{DateTime.now.to_s}",
        # deleteTempBackup: false,
        }
       )
      if response.success?
        user_website.update(enable_backup: true)
        { success: true, message: "Database backup started.", response: response }
      else
        { success: false, message: I18n.t(:panel_error, msg: SolidCp::ErrorHelper.log_solid_cp_error(response, __method__)), response: response }
      end
    end

    alias start_backup backup

    def get_backup_content_summary(id)
      response = super(message: { 
         userId: user.solid_cp_id,
         PackageId: user.packages.first.try(:solid_cp_package_id)
      } )

      if response.success?
        { success: true, message: "Backup Lists", response: response }
      else
        { success: false, message: I18n.t(:panel_error, msg: SolidCp::ErrorHelper.log_solid_cp_error(response, __method__)), response: response }
      end
    end
    alias all get_backup_content_summary

  end
end
