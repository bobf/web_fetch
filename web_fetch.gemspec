# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'web_fetch/version'

# rubocop:disable Metrics/BlockLength
Gem::Specification.new do |s|
  s.name          = 'web_fetch'
  s.version       = WebFetch::VERSION
  s.date          = '2016-10-16'
  s.summary       = 'Async HTTP fetcher'
  s.description   = 'Fetches HTTP responses as batch requests concurrently'
  s.authors       = ['Bob Farrell']
  s.email         = 'robertanthonyfarrell@gmail.com'
  s.files         = File.read(File.join(__dir__, 'manifest')).split
  s.homepage      = 'https://github.com/bobf/web_fetch'
  s.licenses      = ['MIT']
  s.require_paths = ['lib']
  s.executables << 'web_fetch_server'
  s.executables << 'web_fetch_control'

  s.add_dependency 'activesupport', '>= 4.0'
  s.add_dependency 'daemons', '~> 1.2'
  s.add_dependency 'dalli', '~> 2.7'
  s.add_dependency 'em-http-request', '~> 1.1'
  s.add_dependency 'em-logger', '~> 0.1.0'
  s.add_dependency 'eventmachine', '~> 1.0'
  s.add_dependency 'eventmachine_httpserver', '~> 0.2.1'
  s.add_dependency 'faraday', '~> 0.15.4'
  s.add_dependency 'hanami-router', '~> 1.0'
  s.add_dependency 'hanami-utils', '~> 1.0'
  s.add_dependency 'i18n', '>= 0.7'
  s.add_dependency 'rack', '>= 1.6'
  s.add_dependency 'redis', '~> 4.1'
  s.add_dependency 'subprocess', '~> 1.3'

  s.add_development_dependency 'betterp', '~> 0.1.2'
  s.add_development_dependency 'byebug', '~> 9.0'
  s.add_development_dependency 'rake', '~> 12.3'
  s.add_development_dependency 'rspec', '~> 3.5'
  s.add_development_dependency 'rspec-its', '~> 1.2'
  s.add_development_dependency 'rubocop', '~> 0.79.0'
  s.add_development_dependency 'strong_versions', '~> 0.3.2'
  s.add_development_dependency 'webmock', '~> 3.4'
end
# rubocop:enable Metrics/BlockLength
