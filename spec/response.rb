RSpec.describe WebFetch::Request do
  let(:uid) { 'abc123' }
  let(:options) { { uid: uid } }
  let(:client) { WebFetch::Client.new('test-host', 8080) }
  let(:request) { described_class.new(client, options) }
  let(:retrieve_url) { "http://#{client.host}:#{client.port}/retrieve/#{uid}" }

  subject { request }

  it { is_expected.to be_a described_class }

  describe '#fetch' do
    subject { request.fetch(fetch_options) }
    context 'blocking call' do
      let(:fetch_options) { { wait: true } }
      it { is_expected.to have_requested(:get, retrieve_url) }
    end

    context 'non-blocking call' do
      let(:fetch_options) { { wait: false } }
    end

    context 'default (blocking)' do
      subject { request.fetch }
    end
  end
end
