$LOAD_PATH.push File.expand_path('../lib', __FILE__)

version = File.read(File.join(File.dirname(__FILE__), 'VERSION')).strip

Gem::Specification.new do |s|
  s.name = 'stealth'
  s.summary = 'Ruby framework for conversational bots'
  s.description = 'Ruby framework for building conversational bots.'
  s.homepage = 'https://github.com/hellostealth/stealth'
  s.licenses = ['MIT']
  s.version = version
  s.authors = ['Mauricio Gomes', 'Matthew Black']
  s.email = 'mauricio@edge14.com'

  s.add_dependency 'sinatra', '~> 2.0'
  s.add_dependency 'puma', '>= 4.2', '< 6.0'
  s.add_dependency 'thor', '~> 1.0'
  s.add_dependency 'multi_json', '~> 1.12'
  s.add_dependency 'sidekiq', '~> 6.0'
  s.add_dependency 'activesupport', '~> 6.0'

  s.add_development_dependency 'rspec', '~> 3.9'
  s.add_development_dependency 'rspec_junit_formatter', '~> 0.3'
  s.add_development_dependency 'rack-test', '~> 1.1'
  s.add_development_dependency 'mock_redis', '~> 0.22'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.require_paths = ['lib']
end
