Sidekiq.configure_server do |config|
  config.redis = { url: 'redis://10.122.0.2:6379/5' }
end
Sidekiq.configure_client do |config|
  config.redis = { url: 'redis://10.122.0.2:6379/5' }
end
