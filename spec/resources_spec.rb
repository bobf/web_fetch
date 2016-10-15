describe WebFetch::Resources do
  describe '.root' do
    it 'responds with application name' do
      expect(described_class.root(nil)).to eql [200, 'WebFetch']
    end
  end

  describe '.fetch' do
    let(:result) do
      described_class.fetch(requests: [{ url: 'http://google.com' }])
    end

    it 'provides a `fetch` resource' do
      expect(result.first).to eql 200
    end

    it 'responds with json-encoded hash' do
      json = result[1]
      expect(JSON.parse(json)).to be_a Hash
    end
  end

  describe 'retrieve' do
    it 'gives 404 not found when unrecognised uid requested' do
      result = described_class.retrieve(uid: '123')
      expect(result[0]).to eql 404
      expect(JSON.parse(result[1])['error']).to eql I18n.t(:uid_not_found)
    end

    it 'gives 404 not found when unrecognised hash requested' do
      result = described_class.retrieve(hash: 'abc')
      expect(result[0]).to eql 404
      expect(JSON.parse(result[1])['error']).to eql I18n.t(:hash_not_found)
    end
  end
end
