describe WebFetch::Client do
  let(:client) { described_class.new('localhost', 8089) }

  before(:each) do
    stub_request(:any, 'http://blah.blah/success')
      .to_return(body: 'hello, everybody')
  end

  it 'can be instantiated with host and port params' do
    client
  end

  describe '#alive?' do
    it 'confirms server is alive and accepting requests' do
      expect(client.alive?).to be true
    end
  end

  describe '#gather' do
    it 'makes `gather` requests to a running server' do
      result = client.gather([{ url: 'http://blah.blah/success' }])
      expect(result.first[:uid]).to_not be_nil
    end
  end

  describe '#retrieve_by_uid' do
    it 'retrieves a gathered item' do
      result = client.gather([{ url: 'http://blah.blah/success' }])
      uid = result.first[:uid]

      retrieved = client.retrieve_by_uid(uid)
      expect(retrieved[:response][:status]).to eql 200
      expect(retrieved[:response][:body]).to eql 'hello, everybody'
      expect(retrieved[:uid]).to eql uid
    end

    it 'returns nil for non-requested items' do
      client.gather([{ url: 'http://blah.blah/success' }])

      retrieved = client.retrieve_by_uid('lalalala')
      expect(retrieved).to be_nil
    end
  end

  describe '#create' do
    it 'spawns a server and returns a client able to connect' do
      client = described_class.create('localhost', 8077)
      expect(client.alive?).to be true
      client.stop
    end
  end

  describe '#stop' do
    it 'can spawn a server and stop the process when needed' do
      client = described_class.create('localhost', 8077)
      expect(client.alive?).to be true
      client.stop
      expect(client.alive?).to be false
    end
  end
end
