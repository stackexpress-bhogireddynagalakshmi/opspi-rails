module ChatWoot
  class Inbox < Base
    attr_reader :account

    def initialize(account, options = {})
      @account = account
    end

    def create
      response = query({
                         endpoint: "/#{ChatWoot::Config.chatwoot_api_version}/accounts/#{ChatWoot::Config.account_id}/inboxes/",
                         method: :POST,
                         header: authorization_user_header,
                         body: {
                          name: account.name,
                          channel: {
                            type: "web_widget",
                            website_url: account.url, 
                            widget_color: "rgb(0, 156, 224)"
                          }
                         }
                       })

      formatted_response(response, 'create')
    end

    def add_agent_to_inbox
      response = query({
                         endpoint: "/#{ChatWoot::Config.chatwoot_api_version}/accounts/#{ChatWoot::Config.account_id}/inbox_members",
                         method: :POST,
                         header: authorization_user_header,
                         body: {
                          inbox_id: account.inbox_id,
                          user_ids: [ account.user_agent_id]
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
