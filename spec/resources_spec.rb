# frozen_string_literal: true

describe WebFetch::Resources do
  let(:server) { WebFetch::MockServer.new }

  describe '.root' do
    it 'responds with application name' do
      expect(described_class.root(nil, nil))
        .to eql(status: 200, payload: { application: 'WebFetch' })
    end
  end

  describe '.gather' do
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
    it 'gives 404 not found when unrecognised uid requested' do
      response = described_class.retrieve(server, uid: '123')
      expect(response[:status]).to eql 404
      error = response[:payload][:error]
      expect(error).to eql I18n.t(:uid_not_found)
    end

    it 'gives 404 not found when unrecognised hash requested' do
      response = described_class.retrieve(server, hash: 'abc')
      expect(response[:status]).to eql 404
      error = response[:payload][:error]
      expect(error).to eql I18n.t(:hash_not_found)
    end
  end

  describe '.find' do
    it 'gives 404 not found when unrecognised uid requested' do
      response = described_class.find(server, uid: '123')
      expect(response[:status]).to eql 404
      error = response[:payload][:error]
      expect(error).to eql I18n.t(:uid_not_found)
    end

    it 'gives 404 not found when unrecognised hash requested' do
      response = described_class.find(server, hash: 'abc')
      expect(response[:status]).to eql 404
      error = response[:payload][:error]
      expect(error).to eql I18n.t(:hash_not_found)
    end
  end
end
