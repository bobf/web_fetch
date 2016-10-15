require 'celluloid/current'
require 'celluloid/io'
require 'i18n'
require 'json'
require 'digest'
require 'securerandom'

I18n.load_path = Dir['lib/locales/*.yml']
I18n.backend.load_translations
I18n.config.available_locales = :en

require 'web_fetch/concerns/validatable'
require 'web_fetch/server'
require 'web_fetch/router'
require 'web_fetch/resources'
require 'web_fetch/fetcher'
require 'web_fetch/retriever'
require 'web_fetch/client'
