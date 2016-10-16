require 'unirest'

describe WebFetch::Server do
  let(:port) { 8089 }
  let(:host) { 'localhost' }
  let(:host_uri) { "http://#{host}:#{port}" }

  it 'accepts HTTP connections' do
    response = get(host_uri)
    expect(response.code).to eql 200
    expect(response.body['application']).to eql 'WebFetch'
  end

  describe '/fetch' do
    before(:each) do
      stub_request(:any, 'http://blah.blah/success')
      stub_request(:any, 'http://blah.blah/success?a=1')
    end

    it 'responds "Unprocessable Entity" when incomplete params passed' do
      response = post("#{host_uri}/fetch", bob: ':(')
      expect(response.code).to eql 422
    end

    it 'responds with uid for each request' do
      json = JSON.dump(requests: [{ url: 'http://blah.blah/success' }])
      response = post("#{host_uri}/fetch", json: json)
      expect(response.body['requests'].first['uid']).to_not be_empty
    end

    it 'responds with a hash that respects url, query string and headers' do
      params1 = { url: 'http://blah.blah/success' }
      params2 = { url: 'http://blah.blah/success?a=1' }
      params3 = { url: 'http://blah.blah/success',
                  headers: { 'Content-Type' => 'whatever' } }

      responses = [params1, params2, params3].map do |params|
        json = JSON.dump(requests: [params])
        post("#{host_uri}/fetch", json: json)
      end
      hashes = responses.map { |res| res.body['requests'].first['hash'] }
      expect(hashes.uniq.length).to eql 3
    end
  end

  describe '#gather' do
    it 'respects a given url' do
      stub = stub_request(:any, 'http://blah.blah/success')
      json = JSON.dump(requests: [{ url: 'http://blah.blah/success' }])
      post("#{host_uri}/fetch", json: json)
      expect(stub).to have_been_requested
    end

    it 'respects given query parameters' do
      stub = stub_request(:any, 'http://blah.blah/success?a=1')
      json = JSON.dump(requests: [{ url: 'http://blah.blah/success?a=1' }])
      post("#{host_uri}/fetch", json: json)
      expect(stub).to have_been_requested
    end

    it 'respects given headers' do
      stub = stub_request(:any, 'http://blah.blah/success')
             .with(headers: { 'Content-Type' => 'whatever' })
      params = { url: 'http://blah.blah/success',
                 headers: { 'Content-Type' => 'whatever' } }
      json = JSON.dump(requests: [params])
      post("#{host_uri}/fetch", json: json)
      expect(stub).to have_been_requested
    end

    it 'respects given http method' do
      stub = stub_request(:post, 'http://blah.blah/success?a=1')
      json = JSON.dump(requests: [{ url: 'http://blah.blah/success?a=1',
                                    method: 'POST' }])
      post("#{host_uri}/fetch", json: json)
      expect(stub).to have_been_requested
    end
  end

  private

  def get(uri)
    Unirest.get(uri)
  end

  def post(uri, data, json = true)
    headers = { 'Accept' => 'application/json' } if json
    Unirest.post(uri, headers: headers,
                      parameters: data)
  end
end
