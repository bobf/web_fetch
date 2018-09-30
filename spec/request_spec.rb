RSpec.describe WebFetch::Request do
  let(:request) do
    described_class.new do |request|
      request.url = 'http://blah'
      request.method = 'GET'
      request.query = { foo: 'bar' }
      request.headers = { 'Content-Type' => 'application/baz' }
      request.body = 'abc123'
      request.custom = { my_custom_key: 'my_custom_value' }
    end
  end

  let(:hash) do
    {
      url: 'http://blah',
      method: :get,
      query: { foo: 'bar' },
      headers: { 'Content-Type' => 'application/baz' },
      body: 'abc123',
      custom: { my_custom_key: 'my_custom_value' }
    }
  end

  subject { request }
  it { is_expected.to be_a described_class }
  its(:url) { is_expected.to eql 'http://blah' }
  its(:method) { is_expected.to eql :get } # Normalised to lower-case symbols
  its(:query) { is_expected.to eql(foo: 'bar') }
  its(:headers) { are_expected.to eql('Content-Type' => 'application/baz') }
  its(:body) { is_expected.to eql 'abc123' }
  its(:custom) { is_expected.to eql(my_custom_key: 'my_custom_value') }
  its(:to_h) { is_expected.to eql hash }

  describe '#get' do
    let(:request) { described_class.new { |request| } }
    subject { request.method }
    it { is_expected.to eql :get }
  end
end
