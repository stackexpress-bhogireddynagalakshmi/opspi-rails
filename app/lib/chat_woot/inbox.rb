module ChatWoot
  class Inbox < Base
    attr_reader :account

    def initialize(account, options = {})
      @account = account
      # @agent_id = options[:agent_id]
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
      if response.present?
        chat_woot_user = ChatwootUser.find_by(store_account_id: account.id)
        chat_woot_user.update(inbox_id: response.id, website_token: response.website_token)
      end
      formatted_response(response, 'create')
    end

    def add_agent_to_inbox
      response = query({
                         endpoint: "/#{ChatWoot::Config.chatwoot_api_version}/accounts/#{ChatWoot::Config.account_id}/inbox_members",
                         method: :POST,
                         header: authorization_user_header,
                         body: {
                          inbox_id: account.inbox_id,
                          user_ids: [ account.agent_id ]
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
          message: I18n.t('isp_config.something_went_wrong'),
          response: response
        }
      end
    end
  end
end
