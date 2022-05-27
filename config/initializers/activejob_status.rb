
# You should avoid using cache store that are not shared between web and background processes
# (ex: :memory_store).
ActiveJob::Status.store = :redis_cache_store, { url: ENV['REDIS_URL'] }
