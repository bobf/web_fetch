describe WebFetch::Fetcher do
  let(:valid_params) do
    { urls: ['http://localhost:8089'] }
  end

  it 'is initialisable with params' do
    expect(described_class.new(valid_params)).to be_a described_class
  end

  describe '#valid?' do
    context 'invalid' do
      it 'is invalid if `urls` parameter is not passed' do
        fetcher = described_class.new
        expect(fetcher.valid?).to be false
        expect(fetcher.errors).to include I18n.t(:urls_missing)
      end

      it 'is invalid if `urls` is not an array parameter' do
        fetcher = described_class.new(urls: 'hello')
        expect(fetcher.valid?).to be false
        expect(fetcher.errors).to include I18n.t(:urls_not_array)
      end

      it 'is invalid if `urls` is an empty array' do
        fetcher = described_class.new(urls: [])
        expect(fetcher.valid?).to be false
        expect(fetcher.errors).to include I18n.t(:urls_empty)
      end
    end

    context 'valid' do
      it 'is valid when passed valid params' do
        expect(described_class.new(valid_params).valid?).to be true
      end
    end
  end
end
