module Spree
  module Admin
     module Mail
      # Mail blacklist Controller
      class SpamFilterBlacklistsController < SpamFiltersController

        def resource_index_path
          redirect_to admin_mail_spam_filter_blacklists_path
        end

        def filter_type_params
          { wb: 'B'}
        end

        def isp_config_api
          current_spree_user.isp_config.spam_filter_blacklist
        end

      end
     end
  end
end