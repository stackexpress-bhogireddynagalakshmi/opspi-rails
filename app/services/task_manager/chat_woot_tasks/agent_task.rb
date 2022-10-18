module TaskManager
  module ChatWootTasks
    class AgentTask < TaskManager::ChatWootTasks::Base
      
      def call
        case task[:type]
        when 'create_chat_agent'
          create_agent
        # when 'update_mail_box'
        # when 'delete_mail_box'
        end 
      end

      private

      def create_agent
        @response = ChatWoot::Agent.new(@store).create
      end
    end
  end
end