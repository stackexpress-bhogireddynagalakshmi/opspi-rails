module IspConfig
  module Mail
     #blacklist API endpoints
    class SpamFilterBlacklist < SpamFilter
      def get_endpoint
        '/json.php?mail_spamfilter_blacklist_get'
      end

      def create_endpoint
        '/json.php?mail_spamfilter_blacklist_add'
      end

      def update_endpoint
        '/json.php?mail_spamfilter_blacklist_update'
      end

      def delete_endpoint
        '/json.php?mail_spamfilter_blacklist_delete'
      end

      def all
        super('B')
      end
    end
  end
end