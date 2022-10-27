module TaskManager
  module HostingPanelTasks
     class MailForwardTask < TaskManager::HostingPanelTasks::Base
      
      def call
        case task[:type]
        when 'create_mail_forward'
           create_mail_forward
        when 'update_mail_forward'
        when 'delete_mail_forward'
          delete_mail_forward
        end 
      end

      private
      def create_mail_forward
        @response = isp_config_api.create(resource_params)
      end

      def delete_mail_forward
        @response = isp_config_api.destroy(@data[:id])
      end

      def isp_config_api
       current_spree_user.isp_config.mail_forward
      end
    end
  end
end