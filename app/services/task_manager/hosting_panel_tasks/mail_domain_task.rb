module TaskManager
  module HostingPanelTasks
     class MailDomainTask < TaskManager::HostingPanelTasks::Base
      
      def call
        case task[:type]
        when 'create_mail_domain'
          create_mail_domain
        when 'update_mail_domain'
        when 'delete_mail_domain'
          delete_mail_domain
        end 
      end

      private
      def create_mail_domain
        @response = isp_config_api.create(resource_params)
      end

      def delete_mail_domain
        isp_config_api.destroy(@data[:id])
      end

      def isp_config_api
        @user.isp_config.mail_domain
      end
    end
  end
end