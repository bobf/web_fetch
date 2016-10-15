describe WebFetch::Retriever do
  let(:valid_params) { { uid: 'abc123' } }

  it 'is initialisable with params' do
    expect(described_class.new(valid_params)).to be_a described_class
  end

  describe 'validation' do
    context 'valid' do
      it 'is valid when `uid` given' do
        retriever = described_class.new(uid: 'abc123')
        expect(retriever.valid?).to be true
      end

      it 'is valid when `hash` given' do
        retriever = described_class.new(hash: 'def456')
        expect(retriever.valid?).to be true
      end
    end

    context 'invalid' do
      it 'is invalid if both `hash` and `uid` given' do      
        retriever = described_class.new(hash: 'def456', uid: 'abc123')
        expect(retriever.valid?).to be false
        expect(retriever.errors).to include I18n.t(:hash_or_uid_but_not_both)
      end

      it 'is invalid if neither `hash` nor `uid` given' do      
        retriever = described_class.new({})
        expect(retriever.valid?).to be false
        expect(retriever.errors).to include I18n.t(:missing_hash_and_uid)
      end
    end
  end

  describe '#find' do
    it 'returns `nil` when given uid has not been requested' do
      retriever = described_class.new(uid: 'nope')
      expect(retriever.find).to be_nil
    end

    it 'returns `nil` when given hash has not been requested' do
      retriever = described_class.new(hash: 'also nope')
      expect(retriever.find).to be_nil
    end

    it 'returns payload when request has been retrieved' do
      fetcher = WebFetch::Fetcher.new({ requests: [{ url: 'http://localhost:8089' }] })
      response = fetcher.start
      retriever = described_class.new(uid: response[:requests].first[:uid])
      pending 'No way to make this pass until back end is implemented'
      expect(retriever.find[:body]).to eql 'hmm'
    end
  end
end
