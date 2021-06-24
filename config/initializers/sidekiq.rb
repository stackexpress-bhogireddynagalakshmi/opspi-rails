Sidekiq.configure_server do |config|
  config.redis = { url: ENV['REDIS_URL'] }
  #config.server_middleware do |chain|
  #  chain.add Middleware::Server::RetryJobs, :max_retries => 3
  #end
end
Sidekiq.configure_client do |config|
  config.redis = {  url: ENV['REDIS_URL']  }
end
