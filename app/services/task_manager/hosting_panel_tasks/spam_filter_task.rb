module TaskManager
  module HostingPanelTasks
    class SpamFilterTask < TaskManager::HostingPanelTasks::Base
      attr_reader :spam_filter
      
      def call
        @spam_filter = UserSpamFilter.find(@data[:id])

        case task[:type]
        when 'create_spam_filter'
        when 'update_spam_filter'
        when 'delete_spam_filter'
          delete_spam_filter
        end
      end

      private
      def create_spam_filter
        #@response = isp_config_api.create(resource_params)
      end

      def delete_spam_filter
        @response = isp_config_api.destroy(@data[:id])
      end

      def isp_config_api
        if spam_filter&.persisted? && spam_filter.wb == 'B' 
          current_spree_user.isp_config.spam_filter_blacklist
        else
          current_spree_user.isp_config.spam_filter_whitelist
        end
      end
    end
  end
end
