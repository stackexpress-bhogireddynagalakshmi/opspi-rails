
# frozen_string_literal: true

module Spree
  module Admin
    module Mail
      # Mail Statistics controller
      class StatisticsController < Spree::Admin::BaseController
        before_action :ensure_hosting_panel_access
        def mailbox_quota
          response = mail_statistics_api.all_mailbox_quotas || []
          @mailbox_quotas = if response[:success]
                              response[:response].response
                            else
                              []
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
