Gem::Specification.new do |s|
  s.name          = 'web_fetch'
  s.version       = '0.0.0'
  s.date          = '2016-10-16'
  s.summary       = 'Async HTTP fetcher'
  s.description   = 'Fetches HTTP responses as batch requests concurrently'
  s.authors       = ['Bob Farrell']
  s.email         = 'robertanthonyfarrell@gmail.com'
  s.files         = `git ls-files`.split($RS)
  s.require_paths = ['lib']
  s.executables << 'web_fetch_server'

  s.add_dependency 'eventmachine'
  s.add_dependency 'eventmachine_httpserver'
  s.add_dependency 'em-http-request'
  s.add_dependency 'hanami-router'
  s.add_dependency 'i18n'
  s.add_dependency 'rack'
  s.add_dependency 'unirest'
  s.add_dependency 'childprocess'

  s.add_development_dependency 'rspec'
  s.add_development_dependency 'byebug'
  s.add_development_dependency 'webmock'
end
