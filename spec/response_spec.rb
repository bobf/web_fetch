RSpec.describe WebFetch::Response do
  let(:uid) { 'abc123' }
  let(:options) { { uid: uid } }
  let(:client) { WebFetch::Client.new('test-host', 8080) }
  let(:response) { described_class.new(client, options) }
  let(:retrieve_url) { "http://#{client.host}:#{client.port}/retrieve/#{uid}" }
  let(:find_url) { "http://#{client.host}:#{client.port}/find/#{uid}" }

  subject { response }

  it { is_expected.to be_a described_class }

  describe '#fetch' do
    before do
      stub_request(:get, retrieve_url).to_return(body: {}.to_json)
      stub_request(:get, find_url).to_return(body: {}.to_json)
    end

    subject { response.fetch(fetch_options) }

    context 'blocking call' do
      let(:fetch_options) { { wait: true } }
      it { is_expected.to have_requested(:get, retrieve_url) }
    end

    context 'non-blocking call' do
      let(:fetch_options) { { wait: false } }
      it { is_expected.to have_requested(:get, find_url) }
    end

    context 'default (blocking)' do
      subject { response.fetch }
      it { is_expected.to have_requested(:get, retrieve_url) }
    end
  end
end
