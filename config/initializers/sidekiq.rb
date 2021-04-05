Sidekiq.configure_server do |config|
  config.redis = { url: 'redis://139.59.18.196:6379/5' }
end

Sidekiq.configure_client do |config|
  config.redis = { url: 'redis://139.59.18.196:6379/5' }
end