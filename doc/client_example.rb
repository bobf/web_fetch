# Run me with:
# RUBYLIB=lib/ bundle exec ruby doc/client_example.rb
require 'web_fetch'
begin
  cli = WebFetch::Client.create('localhost', 8077)
  results = cli.fetch([
                        { url: 'http://localhost:8077/' },
                        { url: 'http://yahoo.com/' },
                        { url: 'http://lycos.com/' },
                        { url: 'http://google.com/' }
                      ])
  results.each do |res|
    p cli.retrieve_by_uid(res[:uid])
  end
rescue
  cli.stop
ensure
  cli.stop
end
