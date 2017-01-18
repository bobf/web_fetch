# WebFetch

## Overview

WebFetch is an asynchronous HTTP proxy server that accepts multiple requests for HTTP retrieval, immediately returning a token for each request, and then allowing that token to be redeemed later when the entity has fully responded.

This permits issuing multiple HTTP requests in parallel, in a fully encapsulated and external process, without having to resort to multi-threading, multi-processing, or complex non-blocking IO implementations.  [EventMachine][1] is used to handle the heavy lifting.

![WebFetch architecture][2]

## Getting Started

Although WebFetch runs as a web server and provides all functionality over a RESTful API (see below), the simplest way to use it is with its Ruby client implementation, which wraps the HTTP API for you, using [Faraday][3]. This also serves as a [reference][4] for writing WebFetch clients in other languages.

In your `Gemfile`, add:

``` ruby
gem 'web_fetch', git: 'https://github.com/bobf/web_fetch.git'
```

and update your bundle:

``` ruby
bundle install
```

Create, connect to, and wrap a Ruby client object around a new WebFetch server instance, listening as `localhost` on port `8077`:

``` ruby
require 'web_fetch'
client = WebFetch::Client.create('localhost', 8077)
```

Issue some requests [asynchronously]:

``` ruby
requests = [{ url: 'http://foobar.baz/' },
            { url: 'http://barfoo.baz/foobar',
              headers: { 'User-Agent' => 'Foo Browser' } },
              query: { foo: 'what is foo', bar: 'what is baz' } ]
jobs = client.gather(requests)
```

Retrieve the responses [synchronously - *any result that has not yet arrived will block until it has arrived while other requests continue to run in parallel*]:

``` ruby
responses = []
jobs.each do |job|
  response = client.retrieve_by_uid(job[:uid])
  responses.push(response)
end
```

See [a working example][5]

## HTTP API

If you need to use the WebFetch server's HTTP API directly refer to the [Swagger API Reference][6]

## Managing the WebFetch process yourself

You may want to run the WebFetch server yourself rather than instantiate it via the client. For this case, the executable `bin/web_fetch_server` is provided.

To connect to an existing process, use `WebFetch::Client.new` rather than `WebFetch::Client.create`. For example:

``` ruby
WebFetch::Client.new('localhost', 8087)
```

## WebFetch Client request options

`WebFetch::Client#gather` accepts an array of hashes which may contain the following parameters:

  * `url`: The target URL [string]
  * `headers`: HTTP headers [hash]
  * `query`: Query parameters [hash]
  * `method`: HTTP method (default: `"GET"`) [string]
  * `body`: HTTP body [string]

These parameters will all be used (where provided) when initiating the HTTP request on the target.

Arbitrary parameters can also be passed and will be returned by `#gather` (though they will not be used to construct the HTTP request). This allows tagging requests with arbitrary information if you need to identify them in a particular way. For example, you may want to generate your own unique identifier for a request, in which case you could do:

``` ruby
client.gather([{ url: 'http://foobar.baz', my_unique_id: '123-456-789' }])
# [{:request=>{:url=>"http://foobar.baz", :my_unique_id=>"123-456-789"}, :hash=>"7c511911d16e1072363fa1653bdd93df65208901", :uid=>"1fb4ee7a-9fc0-4896-9af2-7cbdf234a468"}]
```

## Logging

WebFetch logs to STDERR by default. An alternative log file can be set either
by passing `--log /path/to/logfile` to the command line server, or by passing
`log: '/path/to/logfile'` to `WebFetch::Client.create`:

```
$ bin/web_fetch_server --log /tmp/web_fetch.log
```

```
client = WebFetch::Client.create('localhost', 8077, log: '/tmp/web_fetch.log')
```

## Contributing

WebFetch uses `rspec` for testing:

```
bundle exec rspec
```

Feel free to fork and create a pull request if you would like to make any changes.

[1]: https://github.com/eventmachine/eventmachine
[2]: doc/web_fetch_architecture.png
[3]: https://github.com/lostisland/faraday
[4]: lib/web_fetch/client.rb
[5]: doc/client_example.rb
[6]: swagger.yaml
