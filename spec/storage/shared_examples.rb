# frozen_string_literal: true

RSpec.shared_examples 'a storage adapter' do
  describe '.store' do
    it 'accepts a key and value to store' do
      expect do
        subject.store(:key, 'value')
      end.to_not raise_error
    end
  end

  describe '.fetch' do
    it 'fetches stored values' do
      subject.store(:key, 'value')
      expect(subject.fetch(:key)).to eql 'value'
    end
  end

  describe '.delete' do
    it 'deletes stored values' do
      subject.store(:key, 'value')
      expect(subject.fetch(:key)).to eql 'value'
      subject.delete(:key)
      expect(subject.fetch(:key)).to eql nil
    end
  end
end
