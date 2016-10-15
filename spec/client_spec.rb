describe WebFetch::Client do
  before(:all) do
    WebFetch::Server.new('localhost', 8089)
  end

  let(:client) { described_class.new('localhost', 8089) }

  it 'can be instantiated with host and port params' do
    client
  end

  describe '#alive?' do
    it 'confirms server is alive and accepting requests' do
      expect(client.alive?).to be true
    end
  end

  describe '#fetch' do
    it 'makes `fetch` requests to a running server' do
      result = client.fetch([{ url: 'http://blah' }])
      expect(result.first[:uid]).to_not be_nil 
    end
  end

  describe '#retrieve' do
    it 'retrieves a fetched item' do
      result = client.fetch([{ url: 'http://blah' }])
      uid = result.first[:uid]

      retrieved = client.retrieve_by_uid(uid)
      pending 'need to implement back end before this will work'
      expect(retrieved.body).to eql 'hmm'
    end

    it 'returns nil for non-requested items' do
      result = client.fetch([{ url: 'http://blah' }])

      retrieved = client.retrieve_by_uid('lalalala')
      expect(retrieved).to be_nil
    end
  end
end
