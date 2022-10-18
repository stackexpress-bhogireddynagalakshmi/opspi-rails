module TaskManager
  module ChatWootTasks
    class InboxTask < TaskManager::ChatWootTasks::Base
      
      def call
        case task[:type]
        when 'create_chat_inbox'
          create_inbox
        end 
      end

      private

      def create_inbox
        @response = ChatWoot::Inbox.new(@store).create
      end
    end
  end
end