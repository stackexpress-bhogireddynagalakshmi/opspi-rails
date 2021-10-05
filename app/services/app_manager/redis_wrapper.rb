module AppManager
  class RedisWrapper
    attr_reader :connection

    def initialize
      Sidekiq.redis do |connection| 
        @connection = connection
      end
    end

    def self.set(key,value)
      connection.set(key, value)
    end

    def self.get(key)
      connection.get(key)
    end

    def self.remove(key)
      connection.del(key)
    end

    private

    def self.connection
      new.connection
    end

  end
end