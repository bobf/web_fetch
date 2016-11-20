Gem::Specification.new do |s|
  s.name          = 'web_fetch'
  s.version       = '0.1.0'
  s.date          = '2016-10-16'
  s.summary       = 'Async HTTP fetcher'
  s.description   = 'Fetches HTTP responses as batch requests concurrently'
  s.authors       = ['Bob Farrell']
  s.email         = 'bob.farrell@phgroup.com'
  s.files         = `git ls-files`.split($RS)
  s.require_paths = ['lib']
  s.executables << 'web_fetch_server'

  s.add_dependency 'eventmachine', '~> 1.0'
  s.add_dependency 'eventmachine_httpserver', '~> 0.2'
  s.add_dependency 'em-http-request', '~> 1.1'
  s.add_dependency 'hanami-router', '~> 0.7'
  s.add_dependency 'i18n', '~> 0.7'
  s.add_dependency 'rack', '~> 1.6'
  s.add_dependency 'childprocess', '~> 0.5'
  s.add_dependency 'faraday', '~> 0.9'

  s.add_development_dependency 'rspec', '~> 3.5'
  s.add_development_dependency 'byebug', '~> 9.0'
  s.add_development_dependency 'webmock', '~> 1.24'
end
