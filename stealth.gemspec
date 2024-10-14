require_relative "lib/stealth/version"

Gem::Specification.new do |s|
  s.name = 'stealth'
  s.summary = 'Ruby framework for conversational bots'
  s.description = 'Ruby framework for building conversational bots.'
  s.homepage = 'https://github.com/hellostealth/stealth'
  s.licenses = ['MIT']
  s.version = '3.0.0.alpha1'
  s.authors = ['Matthew Black']
  s.email = 'm@hiremav.com'

  s.add_dependency 'redis', '~> 5.0'
  s.add_dependency 'sidekiq', '~> 7.0'
  s.add_dependency 'spectre_ai', '~> 1.1.2'

  s.add_development_dependency 'rspec', '~> 3.9'
  s.add_development_dependency 'rack-test', '~> 2.0'
  s.add_development_dependency 'mock_redis', '~> 0.22'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the "allowed_push_host"
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  # spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  # spec.metadata["homepage_uri"] = spec.homepage
  # spec.metadata["source_code_uri"] = "TODO: Put your gem's public repo URL here."
  # spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."

  s.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  end

  s.add_dependency "rails", ">= 7.1.3.4"
end
