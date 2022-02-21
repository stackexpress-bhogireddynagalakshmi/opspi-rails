# frozen_string_literal: true

module IspConfig
  module Mail
    # whitelist API endpoints
    class SpamFilterWhitelist < SpamFilter
      def get_endpoint
        '/json.php?mail_spamfilter_whitelist_get'
      end

      def create_endpoint
        '/json.php?mail_spamfilter_whitelist_add'
      end

      def update_endpoint
        '/json.php?mail_spamfilter_whitelist_update'
      end

      def delete_endpoint
        '/json.php?mail_spamfilter_whitelist_delete'
      end

      def all
        super('W')
      end
    end
  end
end
