Stealth.load_services_config(File.read(File.join(File.dirname(__FILE__), 'services.yml')))

REDIS_URL = ENV['REDIS_URL'] || 'redis://localhost:6379/0'
$redis = Redis.new(:url => REDIS_URL)
