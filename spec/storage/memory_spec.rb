# frozen_string_literal: true

describe WebFetch::Storage::Memory do
  subject(:storage) { described_class.new }

  describe '.store' do
    it 'accepts a key and value to store' do
      expect do
        storage.store(:key, :value)
      end.to_not raise_error
    end
  end

  describe '.fetch' do
    it 'fetches stored values' do
      storage.store(:key, :value)
      expect(storage.fetch(:key)).to eql :value
    end
  end

  describe '.delete' do
    it 'deletes stored values' do
      storage.store(:key, :value)
      expect(storage.fetch(:key)).to eql :value
      storage.delete(:key)
      expect(storage.fetch(:key)).to eql nil
    end
  end
end
