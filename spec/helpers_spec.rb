describe WebFetch::Helpers do
  class HelperIncluder
    include WebFetch::Helpers
  end

  subject { HelperIncluder.new }

  describe '#symbolize' do
    it 'handles variously-nested hashes and symbolizes all keys' do
      nested_hash = { 'a': 1, 'b': { 'c': 2, 'd': [{ 'e': 3 }] } }
      expect(subject.symbolize(nested_hash)).to eql(
        a: 1, b: { c: 2, d: [{ e: 3 }] })
    end
  end
end
