# frozen_string_literal: true

describe WebFetch::Client do
  let(:client) { described_class.new('localhost', 60_085, log: File::NULL) }

  before(:each) do
    stub_request(:any, 'http://blah.blah/success')
      .to_return(body: 'hello, everybody')

    # XXX: This does not do what we would hope in EventMachine context as it
    # locks the entire reactor. I really don't know how to make webmock hook
    # into EM and delay the response so we can test #find_by_uid :(
    stub_request(:any, 'http://blah.blah/slow_success')
      .to_return(body: ->(_req) { sleep(0.1) && 'hi' })
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
    let(:web_request) do
      WebFetch::Request.new do |request|
        request.url = 'http://blah.blah/success'
        request.custom = { my_key: 'my_value' }
      end
    end

    it 'makes `gather` requests to a running server' do
      response = client.gather([web_request])
      expect(response.first).to be_a WebFetch::Promise
      expect(response.first.uid).to_not be_nil
      expect(response.first.custom).to eql(my_key: 'my_value')
      expect(response.first.request).to be_a WebFetch::Request
    end

    it 'passes any WebFetch server errors back to the user' do
      expect { client.gather([]) }.to raise_error WebFetch::ClientError
    end

    context 'handling errors when connecting to WebFetch server' do
      let(:client) { WebFetch::Client.new('localhost', 8090) }

      before do
        stub_request(:any, %r{http://localhost:8090})
          .to_return { raise Faraday::ConnectionFailed, 'foobar' }
      end

      subject { proc { client.gather([web_request]) } }

      it { is_expected.to raise_error WebFetch::ClientError }
    end
  end

  describe '#fetch' do
    let(:responses) { client.gather([{ url: 'http://blah.blah/success' }]) }

    subject { client.fetch(responses.first.uid) }

    it { is_expected.to be_a WebFetch::Response }

    context 'pending' do
      subject { client.fetch('not-ready-yet') }
      it { is_expected.to be_pending }
    end
  end

  describe '#retrieve_by_uid' do
    it 'retrieves a gathered item' do
      response = client.gather([{ url: 'http://blah.blah/success' }])
      uid = response.first.uid

      retrieved = client.retrieve_by_uid(uid)
      expect(retrieved[:response][:status]).to eql 200
      expect(retrieved[:response][:body]).to eql 'hello, everybody'
      expect(retrieved[:response][:response_time]).to be_a Float
      expect(retrieved[:uid]).to eql uid
    end

    it 'returns nil for non-requested items' do
      client.gather([{ url: 'http://blah.blah/success' }])

      retrieved = client.retrieve_by_uid('lalalala')
      expect(retrieved).to be_nil
    end
  end

  describe '#find_by_uid' do
    it 'returns a ready status when has been fetched' do
      pending 'Find a good way to create a slow response without locking EM'
      response = client.gather([{ url: 'http://blah.blah/slow_success' }])
      uid = response.first[:uid]

      found = client.find_by_uid(uid)
      expect(found[:pending]).to be true
    end

    it 'returns nil for non-requested items' do
      client.gather([{ url: 'http://blah.blah/success' }])

      retrieved = client.find_by_uid('lalalala')
      expect(retrieved).to be_nil
    end
  end

  describe '#create' do
    it 'spawns a server and returns a client able to connect' do
      client = described_class.create('localhost', 60_085, log: File::NULL)
      expect(client.alive?).to be true
      client.stop
    end
  end

  describe '#stop' do
    it 'can spawn a server and stop the process when needed' do
      pending <<-PENDING.gsub(/\s+/, ' ')
      I can't quite figure out what's going on here but the parent process
      seems to be holding on to the child process' FDs and keeping the server
      alive. `Client#stop` definitely works though ..."
      PENDING
      client = described_class.create('localhost', 60_085, log: File::NULL)
      expect(client.alive?).to be true
      client.stop
      expect(client.alive?).to be false
    end
  end
end
