# frozen_string_literal: true

describe WebFetch::Storage do
  describe '.store' do
    it 'accepts a key and value to store' do
      expect do
        described_class.store(:key, :value)
      end.to_not raise_error
    end
  end

  describe '.fetch' do
    it 'fetches stored values' do
      described_class.store(:key, :value)
      expect(described_class.fetch(:key)).to eql :value
    end
  end

  describe '.delete' do
    it 'deletes stored values' do
      described_class.store(:key, :value)
      expect(described_class.fetch(:key)).to eql :value
      described_class.delete(:key)
      expect(described_class.fetch(:key)).to eql nil
    end
  end
end
