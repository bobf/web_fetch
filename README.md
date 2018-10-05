# WebFetch

## Overview

WebFetch executes concurrent, asynchronous HTTP requests. It is itself an HTTP server implementing a RESTful API, wrapped by a Ruby client interface. Instead of returning a response, WebFetch immediately returns a *promise* which can be redeemed later when the response has been processed.

This permits issuing multiple HTTP requests in parallel, in a fully encapsulated and external process, without having to resort to multi-threading, multi-processing, or complex non-blocking IO implementations. [EventMachine][1] is used to handle the heavy lifting.

![WebFetch architecture][2]

## Getting Started

In your `Gemfile`, add:

``` ruby
gem 'web_fetch'
```

and update your bundle:

``` ruby
bundle install
```

Require WebFetch in your application:

``` ruby
require 'web_fetch'
```

### Launch or connect to a server

Launch the server from your application (recommended for familiarising yourself
with WebFetch):

``` ruby
client = WebFetch::Client.create('localhost', 8077)
```

Or connect to an existing WebFetch server (recommended for production systems - see [below](#process-management) for more details):

``` ruby
client = WebFetch::Client.new('localhost', 8077)
```

### Create a request

Create a WebFetch request. Note that the request will not begin until the next step:

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

### Gather responses

Ask WebFetch to begin gathering your HTTP requests in the background:

``` ruby
promises = client.gather([request])
```

`WebFetch::Client#gather` accepts an array of `WebFetch::Request` objects and immediately returns an array of `WebFetch::Promise` objects. WebFetch will process all requests in the background concurrently.

To retrieve the result of a request, call `WebFetch::Promise#fetch`

``` ruby
result = promises.first.fetch

# Available methods:
result.body
result.headers
result.status # HTTP status code
result.success? # False if a network error (not HTTP error) occurred
result.error # Underlying network error if applicable
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

In some cases you may need to fetch the result of a request in a different context to which you initiated it. A unique ID is available for each *Promise* which can be used to fetch the result from a separate *Client* instance:

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

This can be useful if your web application initiates requests in one controller action and fetches them in another; the `uid` can be stored in a database and used to fetch the request later on.

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

## Managing the WebFetch process yourself <a name='process-management'></a>

For production systems it is advised that you run the WebFetch server separately rather than instantiate it via the client. For this case, the executable `bin/web_fetch_control` is provided. Daemonisation is handled by the [daemons][7] gem.

WebFetch can be started in the terminal with output going to STDOUT or as a daemon.

Run the server as a daemon:

```
$ web_fetch_control start
```

Run the server in the terminal:

```
$ web_fetch_control run
```

Stop the server:

```
$ web_fetch_control stop
```

To pass options to WebFetch, pass `--` to `web_fetch_control` and add all WebFetch options afterwards.

Available options:

```
--port 60087
--host localhost
--pidfile /tmp/web_fetch.pid
--log /var/log/web_fetch.log
```

e.g.:

```
web_fetch_control run -- --port 8000 --host 0.0.0.0
```

No pid file will be created unless the `--pidfile` parameter is passed. It is recommended to use a process monitoring tool (e.g. `monit` or `systemd`) to monitor the WebFetch process.

When running as a daemon, WebFetch will log to the null device so it is advised to always pass `--log` in this case.

## Docker

To use WebFetch in Docker you can either use the provided [`Dockerfile`](docker/Dockerfile) or the public image [`web_fetch/web_fetch`](https://hub.docker.com/r/webfetch/webfetch/)

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
