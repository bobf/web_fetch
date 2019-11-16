# frozen_string_literal: true

describe WebFetch::Gatherer do
  let(:storage) { double }

  let(:valid_params) do
    { requests: [
      { url: 'http://localhost:60085' },
      { url: 'http://remotehost:8089' }
    ] }
  end

  it 'is initialisable with params' do
    expect(described_class.new(storage, valid_params)).to be_a described_class
  end

  describe 'validation' do
    context 'invalid' do
      it 'is invalid if `requests` parameter is not passed' do
        gatherer = described_class.new(storage, {})
        expect(gatherer.valid?).to be false
        expect(gatherer.errors).to include I18n.t(:requests_missing)
      end

      it 'is invalid if `requests` is not an array parameter' do
        gatherer = described_class.new(storage, requests: 'hello')
        expect(gatherer.valid?).to be false
        expect(gatherer.errors).to include I18n.t(:requests_not_array)
      end

      it 'is invalid if `requests` is an empty array' do
        gatherer = described_class.new(storage, requests: [])
        expect(gatherer.valid?).to be false
        expect(gatherer.errors).to include I18n.t(:requests_empty)
      end

      it 'is invalid if `url` missing from any requests' do
        gatherer = described_class.new(
          storage, requests: [{ url: 'hello' }, {}]
        )
        expect(gatherer.valid?).to be false
        expect(gatherer.errors).to include I18n.t(:missing_url)
      end
    end

    context 'valid' do
      it 'is valid when passed valid params' do
        expect(described_class.new(storage, valid_params).valid?).to be true
      end
    end
  end

  describe '#start' do
    let(:http) do
      double(new: double(public_send: double(callback: nil, errback: nil)))
    end

    let(:logger) { double(debug: nil) }

    before do
      stub_request(:get, 'http://remotehost:8089/').to_return(status: 200)
      stub_request(:get, 'http://blah/').to_return(status: 200)
      stub_request(:put, 'http://blah/').to_return(status: 200)
      stub_request(:get, 'http://hello/').to_return(status: 200)
    end

    it 'returns a hash containing sha1 hashes of requests' do
      deferred = double(callback: nil, errback: nil)
      http = double(new: double(public_send: deferred))
      response = described_class.new(storage, valid_params, logger, http).start
      hash = Digest::SHA1.new.digest(JSON.dump(valid_params[:requests].first))
      expect(response[:requests].first[:hash]).to eql Digest.hexencode(hash)
    end

    it 'respects url, headers, http method and query when calculating sha1' do
      req1 = { url: 'http://blah', query_string: 'a=1',
               headers: { 'Content-Type' => 'whatever' } }
      req2 = { url: 'http://blah', query_string: 'b=2',
               headers: { 'Content-Type' => 'whatever' } }
      req3 = { url: 'http://hello', query_string: 'a=1',
               headers: { 'Content-Type' => 'whatever' } }
      req4 = { url: 'http://blah', query_string: 'a=1',
               headers: { 'Content-Type' => 'hello' } }
      req5 = { url: 'http://blah', query_string: 'a=1',
               headers: { 'Content-Type' => 'hello' },
               method: 'PUT' }
      responses = [req1, req2, req3, req4, req5].map do |req|
        described_class.new(
          storage, { requests: [req] }, logger, http
        ).start
      end
      hashes = responses.map { |res| res[:requests].first[:hash] }
      expect(hashes.uniq.length).to eql 5
    end

    it 'returns a hash containing unique IDs for requests' do
      response = described_class.new(storage, valid_params, logger, http).start
      uid1 = response[:requests][0][:uid]
      uid2 = response[:requests][1][:uid]
      expect(uid1).to_not eql uid2
    end

    describe 'auxiliary request data' do
      it 'is included in response' do
        # Ensure that the requester can embed their own identifiers to link to
        # the uid of the delegated request
        params = { requests: [url: 'http://blah/', bob: 'hello'] }
        response = described_class.new(storage, params, logger, http).start
        expect(response[:requests].first[:request][:bob]).to eql 'hello'
      end

      it 'does not affect request hash' do
        # Ensure that only pertinent values are used to compute hash (i.e.
        # adding auxiliary data will still allow retrieval by hash for
        # otherwise duplicate requests
        params1 = { requests: [url: 'http://blah', bob: 'hello'] }
        response1 = described_class.new(storage, params1, logger, http).start

        params2 = { requests: [url: 'http://blah', not_bob: 'good bye'] }
        response2 = described_class.new(storage, params2, logger, http).start
        expect(response1[:requests][0][:hash])
          .to eql response2[:requests][0][:hash]
      end
    end
  end
end
