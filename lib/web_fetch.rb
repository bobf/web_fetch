require 'eventmachine'
require 'evma_httpserver'
require 'em-http'
require 'i18n'
require 'json'
require 'digest'
require 'securerandom'
require 'faraday'
require 'childprocess'
require 'active_support/gzip'

locales_path = File.expand_path('../../config/locales/*.yml', __FILE__)

# Locales heavily
if Gem.loaded_specs.key?('rails')
  I18n.load_path += Dir[locales_path]
else
  I18n.load_path += Dir[locales_path]
  I18n.backend.load_translations
  I18n.config.available_locales = :en
end

require 'web_fetch/helpers'
require 'web_fetch/concerns/validatable'
require 'web_fetch/storage'
require 'web_fetch/server'
require 'web_fetch/router'
require 'web_fetch/resources'
require 'web_fetch/gatherer'
require 'web_fetch/retriever'
require 'web_fetch/client'
require 'web_fetch/version'
