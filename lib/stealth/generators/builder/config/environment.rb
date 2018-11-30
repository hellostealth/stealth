REDIS_URL = ENV['REDIS_URL'] || 'redis://localhost:6379/0'
$redis = Redis.new(:url => REDIS_URL)
