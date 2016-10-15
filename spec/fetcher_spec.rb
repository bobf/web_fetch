describe WebFetch::Fetcher do
  let(:valid_params) do
    { requests: [
        { url: 'http://localhost:8089' },
        { url: 'http://remotehost:8089' }
      ]
    }
  end

  it 'is initialisable with params' do
    expect(described_class.new(valid_params)).to be_a described_class
  end

  describe 'validation' do
    context 'invalid' do
      it 'is invalid if `requests` parameter is not passed' do
        fetcher = described_class.new
        expect(fetcher.valid?).to be false
        expect(fetcher.errors).to include I18n.t(:requests_missing)
      end

      it 'is invalid if `requests` is not an array parameter' do
        fetcher = described_class.new(requests: 'hello')
        expect(fetcher.valid?).to be false
        expect(fetcher.errors).to include I18n.t(:requests_not_array)
      end

      it 'is invalid if `requests` is an empty array' do
        fetcher = described_class.new(requests: [])
        expect(fetcher.valid?).to be false
        expect(fetcher.errors).to include I18n.t(:requests_empty)
      end

      it 'is invalid if `url` missing from any requests' do
        fetcher = described_class.new(requests: [{ url: 'hello' }, {}])
        expect(fetcher.valid?).to be false
        expect(fetcher.errors).to include I18n.t(:missing_url)
      end
    end

    context 'valid' do
      it 'is valid when passed valid params' do
        expect(described_class.new(valid_params).valid?).to be true
      end
    end
  end

  describe '#start' do
    it 'returns a hash containing sha1 hashes of requests' do
      result = described_class.new(valid_params).start
      hash = Digest::SHA1.new.digest(JSON.dump(valid_params[:requests].first))
      expect(result[:requests].first[:hash]).to eql Digest.hexencode(hash)
    end

    it 'returns a hash containing unique IDs for requests' do
      result = described_class.new(valid_params).start
      uid1 = result[:requests][0][:uid]
      uid2 = result[:requests][1][:uid]
      expect(uid1).to_not eql uid2
    end

    describe 'auxiliary request data' do
      it 'is included in response' do
        # Ensure that the requester can embed their own identifiers to link to
        # the uid of the delegated request
        params = { requests: [ url: '-', bob: 'hello' ] }
        result = described_class.new(params).start
        expect(result[:requests].first[:request][:bob]).to eql 'hello'
      end

      it 'does not affect request hash' do
        # Ensure that only pertinent values are used to compute hash (i.e.
        # adding auxiliary data will still allow retrieval by hash for
        # otherwise duplicate requests
        params1 = { requests: [ url: 'http://blah', bob: 'hello' ] }
        result1 = described_class.new(params1).start

        params2 = { requests: [ url: 'http://blah', not_bob: 'good bye' ] }
        result2 = described_class.new(params2).start
        expect(result1[:requests][0][:hash]).to eql result2[:requests][0][:hash]
      end
    end
  end
end
