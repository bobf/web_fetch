# frozen_string_literal: true

RSpec.describe WebFetch::Promise do
  let(:uid) { 'abc123' }
  let(:request) { { url: 'http://blah', custom: { my_key: 'my_value' } } }
  let(:options) { { uid: uid, request: request } }
  let(:client) { WebFetch::Client.new('test-host', 8080) }
  let(:retrieve_url) { "http://#{client.host}:#{client.port}/retrieve/#{uid}" }
  let(:find_url) { "http://#{client.host}:#{client.port}/find/#{uid}" }

  let(:client_success) do
    double(fetch: double('success',
      complete?: true, pending?: false, success?: true, error: nil
    ))
  end

  let(:client_failure) do
    double(fetch: double('failure',
      complete?: true, pending?: false, success?: false, error: 'foo'
    ))
  end

  let(:client_pending) do
    double(fetch: double('pending',
      complete?: false, pending?: true, error: nil
    ))
  end

  let(:client_not_started) do
    double('not started', fetch: nil)
  end

  subject(:promise) { described_class.new(client, options) }

  it { is_expected.to be_a described_class }

  describe '#fetch' do
    before do
      stub_request(:get, retrieve_url).to_return(body: { request: {} }.to_json)
      stub_request(:get, find_url).to_return(body: { request: {} }.to_json)
    end

    subject { promise.fetch(fetch_options) }

    context 'blocking call' do
      let(:fetch_options) { { wait: true } }
      it { is_expected.to have_requested(:get, retrieve_url) }
    end

    context 'non-blocking call' do
      let(:fetch_options) { { wait: false } }
      it { is_expected.to have_requested(:get, find_url) }
    end

    context 'default (blocking)' do
      subject { promise.fetch }
      it { is_expected.to have_requested(:get, retrieve_url) }
    end
  end

  describe '#response' do
    before do
      stub_request(:get, retrieve_url)
        .to_return(
          body: {
            response: { success: true, body: 'abc123' }, request: {}
          }.to_json
        )
      promise.fetch
    end

    subject { promise.response }
    it { is_expected.to be_a WebFetch::Response }
    its(:body) { is_expected.to eql 'abc123' }
  end

  describe '#complete?, #success?, #pending?, #error' do
    before { promise.fetch }

    subject { promise }

    context 'request succeeded' do
      let(:client) { client_success }
      its(:complete?) { is_expected.to be true }
      its(:success?) { is_expected.to be true }
      its(:pending?) { is_expected.to be false }
      its(:error) { is_expected.to be_nil }
    end

    context 'request failed' do
      let(:client) { client_failure }
      its(:complete?) { is_expected.to be true }
      its(:success?) { is_expected.to be false }
      its(:pending?) { is_expected.to be false }
      its(:error) { is_expected.to eql 'foo' }
    end

    context 'request pending' do
      let(:client) { client_pending }
      its(:complete?) { is_expected.to be false }
      its(:success?) { is_expected.to be false }
      its(:pending?) { is_expected.to be true }
      its(:error) { is_expected.to be_nil }
    end

    context 'request not started' do
      let(:client) { client_not_started }
      its(:complete?) { is_expected.to be false }
      its(:success?) { is_expected.to be false }
      its(:pending?) { is_expected.to be false }
      its(:error) { is_expected.to be_nil }
    end
  end

  describe '#request' do
    subject { promise.request }
    it { is_expected.to be_a WebFetch::Request }
    its(:custom) { is_expected.to eql(my_key: 'my_value') }
  end

  describe '#custom' do
    # I think it's good to expose this directly on the promise even though it's
    # accessible as `response.request.custom`
    its(:custom) { is_expected.to eql(my_key: 'my_value') }
  end
end
