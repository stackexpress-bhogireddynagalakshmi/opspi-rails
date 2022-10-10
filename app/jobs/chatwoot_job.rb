class ChatwootJob < ApplicationJob
    queue_as :default

    def perform(store)
      chat_agent = ChatWoot::Agent.new(store).create
      chat_inbox = ChatWoot::Inbox.new(store).create
      if chat_agent[:success] && chat_inbox[:success]
        chatwoot_user = ChatwootUser.new({ store_account_id: store.account.id, inbox_id: chat_inbox[:response].id, website_token: chat_inbox[:response].website_token})
        chatwoot_user.save!
        ChatWoot::Inbox.new(chatwoot_user,agent_id: chat_agent[:response].id).add_agent_to_inbox
      end
    end
end
  