module StoreManager
  class ChatWootResourceCreator < ApplicationService
    attr_reader :store, :user

    def initialize(store, options = {})
      @store = store
      @user = Spree::User.find_by_email(store.admin_email)
    end

    def call
      @tasks = []
          
      build_tasks

      TaskManager::TaskProcessor.new(user, @tasks).call
      
    end

    private
    def build_tasks
      prepare_chatwoot_agent_task
      prepare_chatwoot_inbox_task
      prepare_assign_agent_with_inbox_task

      @tasks = @tasks.flatten
    end

    def prepare_chatwoot_agent_task
      @tasks <<
        {
          id: 1,
          type: "create_chat_agent",
          data: {
            store_id: store.id
          },
          depends_on: nil,
          sidekiq_job_id: nil
        }
    end

    def prepare_chatwoot_inbox_task
      @tasks <<
        {
          id: 2,
          type: "create_chat_inbox",
          data: {
            store_id: store.id
          },
          depends_on: 1,
          sidekiq_job_id: nil
        }
    end

    def prepare_assign_agent_with_inbox_task
      @tasks <<
        {
          id: 3,
          type: "create_chat_agent_with_inbox",
          data: {
            store_id: store.id
          },
          depends_on: 2,
          sidekiq_job_id: nil
        }
    end

  end
end