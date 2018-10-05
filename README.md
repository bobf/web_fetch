# WebFetch

## Overview

WebFetch is an asynchronous HTTP proxy server that accepts multiple requests for HTTP retrieval, immediately returning a token for each request, allowing that token to be redeemed later when the entity has fully responded.

This permits issuing multiple HTTP requests in parallel, in a fully encapsulated and external process, without having to resort to multi-threading, multi-processing, or complex non-blocking IO implementations. [EventMachine][1] is used to handle the heavy lifting.

![WebFetch architecture][2]

## Getting Started

Although WebFetch runs as a web server and provides all functionality over a RESTful API (see below), the simplest way to use it is with its Ruby client implementation which wraps the HTTP API for you using [Faraday][3]. This also serves as a [reference][4] for writing WebFetch clients in other languages.

In your `Gemfile`, add:

``` ruby
gem 'web_fetch'
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

### Creating a request

``` ruby
request = WebFetch::Request.new do |req|
  req.url = 'http://foobar.baz'
  req.headers = { 'User-Agent' => 'Foo Browser' }
  req.query = { foobar: 'baz' }
  req.method = :get
  req.body = 'foo bar baz'
  req.custom = { my_id: '123' }
end
```

Only `url` is required. The default HTTP method is `GET`.

Anything assigned to `custom` will be returned with the final result (available by calling `#custom` on the result). This may be useful if you need to tag each request with your own custom identifier, for example. Anything you assign here will have no bearing whatsoever on the HTTP request.

If you prefer to build a request from a hash, you can call `WebFetch::Request.from_hash`

``` ruby
request = WebFetch::Request.from_hash(
  url: 'http://foobar.baz',
  headers: { 'User-Agent' => 'Foo Browser' },
  query: { foobar: 'baz' },
  method: :get,
  body: 'foo bar baz',
  custom: { my_id: '123' }
)
```

### Gathering responses

``` ruby
promises = client.gather([request])
```

`WebFetch::Client#gather` accepts an array of `WebFetch::Request` objects and immediately returns an array of `WebFetch::Promise` objects. WebFetch will process all requests in the background concurrently.

To retrieve the result of a request, call `WebFetch::Promise#fetch`

``` ruby
result = promises.first.fetch
puts result.body
puts result.headers
puts result.status
```

Note that `WebFech::Promise#fetch` will block until the result is complete by default. If you want to continue executing other code if the result is not ready (e.g. to see if any other results are ready), you can pass `wait: false`

``` ruby
result = promises.first.fetch(wait: false)
```

A special value `:pending` will be returned if the result is still processing.

Alternatively, you can call `WebFetch::Promise#complete?` to check if a request has finished before waiting for the response:

``` ruby
result = promises.first.fetch if promises.first.complete?
```

### Fetching results later

In some cases you may need to fetch the result in a different context to which you initiated the request in. A unique ID is available for each *Promise* which can be used to fetch the result from a separate *Client* instance:

``` ruby
client = WebFetch::Client.new('localhost', 8077)
promises = client.gather([
  WebFetch::Request.new { |req| req.url = 'http://foobar.com' }
])
uid = promises.first.uid

# Later ...
client = WebFetch::Client.new('localhost', 8077)
result = client.fetch(uid)
```

(See [below](#new-vs-create) for the difference between `WebFetch::Client.new` and `WebFetch::Client.create`)

This can be useful if your web application initiates requests in one controller action and fetches them in another.

### Stopping the server

When you have finished using the web server, call `WebFetch::Client#stop`

``` ruby
client.stop
```

The server will not automatically stop when your program exits.

## Examples

[Runnable examples][5] are provided for more detailed usage.

## HTTP API

If you need to use the WebFetch server's HTTP API directly refer to the [Swagger API Reference][6]

## Managing the WebFetch process yourself

For production systems it is advised that you run the WebFetch server separately rather than instantiate it via the client. For this case, the executable `bin/web_fetch_control` is provided. Daemonisation is handled by the [daemons][7] gem.

WebFetch can be started in the terminal with output going to STDOUT or as a daemon.

Run the server as a daemon:

```
$ bundle exec bin/web_fetch_control start -- --log /tmp/web_fetch.log
```

**Note that you should always pass `--log` when running as a daemon otherwise all output will go to the null device.**

Run the server in the terminal:

```
$ bundle exec bin/web_fetch_control run -- --port 8080
```

It is further recommended to use a process management tool to monitor the pidfile (pass `--pidfile /path/to/file.pid` to specify an explicit location).

<a name='new-vs-create'></a>To connect to an existing process, use `WebFetch::Client.new` rather than `WebFetch::Client.create`. For example:

``` ruby
WebFetch::Client.new('localhost', 8087)
```

## Logging

WebFetch logs to STDOUT by default. An alternative log file can be set either
by passing `--log /path/to/logfile` to the command line server, or by passing
`log: '/path/to/logfile'` to `WebFetch::Client.create`:

```
$ bundle exec bin/web_fetch_server --log /tmp/web_fetch.log
```

```
client = WebFetch::Client.create('localhost', 8077, log: '/tmp/web_fetch.log')
```

## Contributing

WebFetch uses `rspec` for testing:

```
bin/rspec
```

Rubocop is used for code style governance:

```
bin/rubocop
```

Make sure that any new code you write has an appropriate test and that all Rubocop checks pass.

Feel free to fork and create a pull request if you would like to make any changes.

## License

WebFetch is licensed under the [MIT License][8]. You are encouraged to re-use the code in any way you see fit as long as you give credit to the original author. If you do use the code for any other projects then feel free to let me know but, of course, this is not required.

[1]: https://github.com/eventmachine/eventmachine
[2]: doc/web_fetch_architecture.png
[3]: https://github.com/lostisland/faraday
[4]: lib/web_fetch/client.rb
[5]: doc/examples/
[6]: swagger.yaml
[7]: https://github.com/thuehlinger/daemons
[8]: LICENSE
