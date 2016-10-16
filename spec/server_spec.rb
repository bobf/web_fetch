require 'unirest'

describe WebFetch::Server do
  let(:port) { 8089 }
  let(:host) { 'localhost' }
  let(:host_uri) { "http://#{host}:#{port}" }

  it 'accepts HTTP connections' do
    response = get(host_uri) 
    expect(response.code).to eql 200
    expect(response.body['application']).to eql "WebFetch"
  end

  describe '/fetch' do
    it 'responds "Unprocessable Entity" when incomplete params passed' do
      response = post("#{host_uri}/fetch", { bob: ':(' })
      expect(response.code).to eql 422
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
