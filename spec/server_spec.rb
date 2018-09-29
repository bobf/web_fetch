# frozen_string_literal: true

describe WebFetch::Server do
  let(:port) { 8089 }
  let(:host) { 'localhost' }
  let(:host_uri) { "http://#{host}:#{port}" }

  it 'accepts HTTP connections' do
    response = get(host_uri)
    expect(response.success?).to be true
    expect(JSON.parse(response.body)['application']).to eql 'WebFetch'
  end

  describe '/gather' do
    before(:each) do
      stub_request(:any, 'http://blah.blah/success')
      stub_request(:any, 'http://blah.blah/success?a=1')
    end

    it 'responds "Unprocessable Entity" when incomplete params passed' do
      response = post("#{host_uri}/gather", bob: ':(')
      expect(response.status).to eql 422
    end

    it 'responds with uid for each request' do
      params = { requests: [{ url: 'http://blah.blah/success' }] }
      response = post("#{host_uri}/gather", params)
      expect(JSON.parse(response.body)['requests'].first['uid'])
        .to_not be_empty
    end

    it 'responds with a hash that respects url, query string and headers' do
      params1 = { url: 'http://blah.blah/success' }
      params2 = { url: 'http://blah.blah/success?a=1' }
      params3 = { url: 'http://blah.blah/success',
                  headers: { 'Content-Type' => 'whatever' } }

      responses = [params1, params2, params3].map do |params|
        post("#{host_uri}/gather", requests: [params])
      end
      hashes = responses.map do |res|
        JSON.parse(res.body)['requests'].first['hash']
      end
      expect(hashes.uniq.length).to eql 3
    end
  end

  describe '#gather' do
    it 'respects a given url' do
      stub = stub_request(:any, 'http://blah.blah/success')
      params = { requests: [{ url: 'http://blah.blah/success' }] }
      post("#{host_uri}/gather", params)
      expect(stub).to have_been_requested
    end

    it 'respects given query parameters' do
      stub = stub_request(:any, 'http://blah.blah/success?a=1')
      params = { requests: [{ url: 'http://blah.blah/success?a=1' }] }
      post("#{host_uri}/gather", params)
      expect(stub).to have_been_requested
    end

    it 'respects given headers' do
      stub = stub_request(:any, 'http://blah.blah/success')
             .with(headers: { 'Content-Type' => 'whatever' })
      request = { url: 'http://blah.blah/success',
                  headers: { 'Content-Type' => 'whatever' } }
      post("#{host_uri}/gather", requests: [request])
      expect(stub).to have_been_requested
    end

    it 'respects given http method' do
      stub = stub_request(:post, 'http://blah.blah/success?a=1')
      params = { requests: [{ url: 'http://blah.blah/success?a=1',
                              method: 'POST' }] }
      post("#{host_uri}/gather", params)
      expect(stub).to have_been_requested
    end
  end

  private

  def get(uri)
    Faraday.get(uri)
  end

  def post(uri, params)
    parsed = URI.parse(uri)
    base_uri = "#{parsed.scheme}://#{parsed.host}:#{parsed.port}"
    conn = Faraday.new(url: base_uri)
    conn.post do |request|
      request.url parsed.path
      request.body = params.to_json
    end
  end
end
