describe WebFetch::Resources do
  let(:server) { WebFetch::MockServer.new }

  describe '.root' do
    it 'responds with application name' do
      expect(described_class.root(nil)).to eql(status: 200, payload: 'WebFetch')
    end
  end

  describe '.fetch' do
    let(:result) do
      described_class.fetch(requests: [{ url: 'http://google.com' }],
                            _server: server)
    end

    it 'provides a `fetch` resource' do
      expect(result[:status]).to eql 200
    end

    it 'responds with json-encoded hash' do
      json = result[:payload]
      expect(JSON.parse(json)).to be_a Hash
    end
  end

  describe 'retrieve' do
    it 'gives 404 not found when unrecognised uid requested' do
      result = described_class.retrieve(uid: '123', _server: server)
      expect(result[:status]).to eql 404
      error = JSON.parse(result[:payload])['error']
      expect(error).to eql I18n.t(:uid_not_found)
    end

    it 'gives 404 not found when unrecognised hash requested' do
      result = described_class.retrieve(hash: 'abc', _server: server)
      expect(result[:status]).to eql 404
      error = JSON.parse(result[:payload])['error']
      expect(error).to eql I18n.t(:hash_not_found)
    end
  end
end
