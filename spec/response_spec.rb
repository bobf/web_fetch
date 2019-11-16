# frozen_string_literal: true

RSpec.describe WebFetch::Response do
  let(:response) do
    described_class.new(
      request: {
        response: {
          body: Base64.encode64('abc123'),
          headers: { 'Foo' => 'Bar' },
          error: 'foo error happened',
          status: 200,
          success: false
        },
        pending: false,
        request: { url: 'http://blah/' },
        uid: 'uid123',
        response_time: 123.45
      }
    )
  end

  subject { response }

  it { is_expected.to be_a described_class }
  its(:body) { is_expected.to eql 'abc123' }
  its(:headers) { are_expected.to eql('Foo' => 'Bar') }
  its(:status) { is_expected.to eql 200 }
  its(:pending?) { is_expected.to be false }
  its(:complete?) { is_expected.to be true }
  its(:success?) { is_expected.to be false }
  its(:error) { is_expected.to eql 'foo error happened' }
  its(:uid) { is_expected.to eql 'uid123' }
  its(:response_time) { is_expected.to eql 123.45 }
  its(:request) { is_expected.to be_a WebFetch::Request }

  describe '#request' do
    subject { response.request }
    its(:url) { is_expected.to eql 'http://blah/' }
  end
end
