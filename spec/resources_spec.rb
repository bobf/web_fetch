# frozen_string_literal: true

describe WebFetch::Resources do
  let(:server) { WebFetch::MockServer.new }

  describe '.root' do
    it 'responds with application name' do
      expect(described_class.root(nil, nil))
        .to eql(
          status: 200,
          command: 'root',
          payload: { application: 'WebFetch' }
        )
    end
  end

  describe '.gather' do
    before { stub_request(:any, 'http://google.com').to_return(status: 200) }
    let(:response) do
      described_class.gather(server, requests: [{ url: 'http://google.com' }])
    end

    it 'provides a `gather` resource' do
      expect(response[:status]).to eql 200
    end

    it 'responds with hash' do
      expect(response[:payload]).to be_a Hash
    end
  end

  describe '.retrieve' do
    it 'gives pending when unrecognised uid requested' do
      response = described_class.retrieve(server, uid: '123')
      expect(response[:request][:pending]).to be true
    end

    it 'gives pending when unrecognised hash requested' do
      response = described_class.retrieve(server, hash: 'abc')
      expect(response[:request][:pending]).to be true
    end
  end

  describe '.find' do
    it 'gives pending when unrecognised uid requested' do
      response = described_class.find(server, uid: '123')
      expect(response[:request][:pending]).to be true
    end

    it 'gives pending when unrecognised hash requested' do
      response = described_class.find(server, hash: 'abc')
      expect(response[:request][:pending]).to be true
    end
  end
end
