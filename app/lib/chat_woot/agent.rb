module ChatWoot
    class Agent < Base
      attr_reader :account

      def initialize(account, options = {})
        @account = account
      end
  
      def create
        response = query({
                           endpoint: "/#{ChatWoot::Config.chatwoot_api_version}/accounts/#{ChatWoot::Config.account_id}/agents",
                           method: :POST,
                           header: authorization_user_header,
                           body: {
                            name: account.name,
                            email: account.admin_email,
                            role: "agent",  
                            availability_status: "available",
                            auto_offline: true
                           }
                         })

        formatted_response(response, 'create')
      end
  
     
      private
  
     
      def formatted_response(response, action)
        if response.present? && response.id?
          {
            success: true,
            message: "Added Successfully",
            response: response
          }
        else
          {
            success: false,
            message: I18n.t('isp_config.something_went_wrong', message: response.message),
            response: response
          }
        end
      end
    end
  end
  