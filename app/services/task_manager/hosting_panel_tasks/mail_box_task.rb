module TaskManager
  module HostingPanelTasks
    class MailBoxTask < TaskManager::HostingPanelTasks::Base
      
      def call
        case task[:type]
        when 'create_mail_box'
          create_mail_box
        when 'update_mail_box'
          
        when 'delete_mail_box'
          delete_mail_box
        end 
      end

      private

      def create_mail_box
        @response = mail_user_api.create(resource_params, user_domain: @user_domain)
      end

      def delete_mail_box
        @response = mail_user_api.create(@data[:id])
      end

      def mail_user_api
        @user.isp_config.mail_user
      end
    end
  end
end