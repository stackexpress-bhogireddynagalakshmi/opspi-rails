module StoreManager
  class ChatWootResourceCreator < ApplicationService
    attr_reader :store

    def initialize(store, options = {})
      @store = store
    end

    def call
      provision_chatwoot_account
    end

    def provision_chatwoot_account 
      ChatwootJob.set(wait: 3.second).perform_later(store)
      Rails.logger.info { "ChatwootJob is scheduled to create user resorces on Chatwoot Account " }
    end
    
  end
end