RSpec.describe WebFetch::Response do
  let(:uid) { 'abc123' }
  let(:request) { { url: 'http://blah', custom: { my_key: 'my_value' } } }
  let(:options) { { uid: uid, request: request } }
  let(:client) { WebFetch::Client.new('test-host', 8080) }
  let(:response) { described_class.new(client, options) }
  let(:retrieve_url) { "http://#{client.host}:#{client.port}/retrieve/#{uid}" }
  let(:find_url) { "http://#{client.host}:#{client.port}/find/#{uid}" }

  let(:client_success) do
    double(retrieve_by_uid: { response: { success: true } })
  end

  let(:client_failure) do
    double(retrieve_by_uid: { response: { success: false } })
  end

  let(:client_pending) do
    double(retrieve_by_uid: { pending: true })
  end

  let(:client_not_started) do
    double(retrieve_by_uid: nil)
  end

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

  describe '#result' do
    before do
      stub_request(:get, retrieve_url)
        .to_return(
          body: { response: { success: true, body: 'abc123' } }.to_json
        )
      response.fetch
    end

    subject { response.result }
    it { is_expected.to be_a WebFetch::Result }
    its(:body) { is_expected.to eql 'abc123' }
  end

  describe '#complete?, #success?, #pending?' do
    before { response.fetch }

    subject { response }

    context 'request succeeded' do
      let(:client) { client_success }
      its(:complete?) { is_expected.to be true }
      its(:success?) { is_expected.to be true }
      its(:pending?) { is_expected.to be false }
    end

    context 'request failed' do
      let(:client) { client_failure }
      its(:complete?) { is_expected.to be true }
      its(:success?) { is_expected.to be false }
      its(:pending?) { is_expected.to be false }
    end

    context 'request pending' do
      let(:client) { client_pending }
      its(:complete?) { is_expected.to be false }
      its(:success?) { is_expected.to be false }
      its(:pending?) { is_expected.to be true }
    end

    context 'request not started' do
      let(:client) { client_not_started }
      its(:complete?) { is_expected.to be false }
      its(:success?) { is_expected.to be false }
      its(:pending?) { is_expected.to be false }
    end
  end

  describe '#request' do
    subject { response.request }
    it { is_expected.to be_a WebFetch::Request }
    its(:custom) { is_expected.to eql(my_key: 'my_value') }
  end

  describe '#custom' do
    # I think it's good to expose this directly on the response even though its
    # accessible on as `response.request.custom`
    its(:custom) { is_expected.to eql(my_key: 'my_value') }
  end
end
