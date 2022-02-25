# frozen_string_literal: true

module Spree
  module Admin
    module Mail
      # Mail Whitelist Controller
      class SpamFilterWhitelistsController < SpamFiltersController
        def resource_index_path
          redirect_to admin_mail_spam_filter_whitelists_path
        end

        def filter_type_params
          { wb: 'W' }
        end

        def isp_config_api
          current_spree_user.isp_config.spam_filter_whitelist
        end
      end
    end
  end
end
