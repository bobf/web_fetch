# frozen_string_literal: true

describe WebFetch::Retriever do
  let(:storage) { double(fetch: nil, store: nil) }
  let(:valid_params) { { uid: 'abc123' } }

  it 'is initialisable with params' do
    expect(described_class.new(storage, valid_params, {}))
      .to be_a described_class
  end

  describe 'validation' do
    context 'valid' do
      it 'is valid when `uid` given' do
        retriever = described_class.new(storage, { uid: 'abc123' }, {})
        expect(retriever.valid?).to be true
      end

      it 'is valid when `hash` given' do
        retriever = described_class.new(storage, { hash: 'def456' }, {})
        expect(retriever.valid?).to be true
      end
    end

    context 'invalid' do
      it 'is invalid if both `hash` and `uid` given' do
        retriever = described_class.new(
          storage, { hash: 'def456', uid: 'abc123' }, {}
        )
        expect(retriever.valid?).to be false
        expect(retriever.errors).to include I18n.t(:hash_or_uid_but_not_both)
      end

      it 'is invalid if neither `hash` nor `uid` given' do
        retriever = described_class.new(storage, {}, {})
        expect(retriever.valid?).to be false
        expect(retriever.errors).to include I18n.t(:missing_hash_and_uid)
      end
    end
  end

  describe '#find' do
    it 'returns "pending" when given uid has not been requested' do
      retriever = described_class.new(storage, { uid: 'nope' }, {})
      expect(retriever.find[:pending]).to be true
    end

    it 'returns "pending" when given hash has not been requested' do
      retriever = described_class.new(storage, { hash: 'also nope' }, {})
      expect(retriever.find[:pending]).to be true
    end

    it 'returns payload when request has been retrieved' do
      # This test is somewhat useless as we have to mock the behaviour of our
      # fake Server instance a little too much (since the actual Server object
      # we're interested in exists in a separate EventMachine thread while we
      # run our tests). The full stack is tested by the Client specs, however.
      url = 'http://blah.blah/success'
      stub_request(:any, url)

      gatherer = WebFetch::Gatherer.new(storage, requests: [{ url: url }])
      response = gatherer.start
      uid = response[:requests].first[:uid]
      allow(storage).to receive(:fetch).and_return('test')

      retriever = described_class.new(storage, { uid: uid }, {})
      expect(retriever.find).to eql 'test'
    end
  end
end
