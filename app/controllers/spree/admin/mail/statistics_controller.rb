module Spree
  module Admin
     module Mail
      # Mail Statistics controller
      class StatisticsController < Spree::Admin::BaseController
        
        def mailbox_quota
          response = mail_statistics_api.all_mailbox_quotas || []
          if response[:success]
            @mailbox_quotas  = response[:response].response
          else
            @mailbox_quotas = []
          end
        end

        def mailbox_traffic
          # response = mail_statistics_api.all_mailbox_traffic || []
          # if response[:success]
          #   @mailbox_stats  = response[:response].response
          # else
          #   @mailbox_stats = []
          # end
        end

        private
        
        def mail_statistics_api
          current_spree_user.isp_config.mail_statistics
        end

      end
    end
  end
end