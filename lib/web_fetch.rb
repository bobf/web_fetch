require 'celluloid/current'
require 'celluloid/io'
require 'i18n'

I18n.load_path = Dir['locales/*.yml']
I18n.backend.load_translations
I18n.config.available_locales = :en

require 'web_fetch/server'
require 'web_fetch/router'
require 'web_fetch/resources'
require 'web_fetch/fetcher'
