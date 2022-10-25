module TaskManager
  module HostingPanelTasks
    class MailingTask < TaskManager::HostingPanelTasks::Base
      
      def call
        case task[:type]
        when 'create_mailing_list'
        when 'update_mailing_list'
        when 'delete_mailing_list'
        end
      end

      private
      def create_mailing_list
        @response = isp_config_api.create(resource_params)
      end

      def delete_mailing_list
        @response = isp_config_api.destroy(@data[:id])
      end

      def isp_config_api
        current_spree_user.isp_config.mailing_list
      end
    end
  end
end
