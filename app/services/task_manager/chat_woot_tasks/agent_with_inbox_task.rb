module TaskManager
  module ChatWootTasks
    class AgentWithInboxTask < TaskManager::ChatWootTasks::Base
      attr_reader :chatwoot_user
      
      def call
        @chatwoot_user = ChatwootUser.find_by(store_account_id: resource_params.account.id)
        case task[:type]
        when 'create_chat_agent_with_inbox'
          create_agent_with_inbox
        # when 'update_mail_box'
        # when 'delete_mail_box'
        end 
      end

      private

      def create_agent_with_inbox
        @response = ChatWoot::Inbox.new(chatwoot_user).add_agent_to_inbox
      end
    end
  end
end