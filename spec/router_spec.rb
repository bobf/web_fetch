describe WebFetch::Router do
  let(:router) { described_class.new }

  it 'can be initialised' do
    expect(router).to be_a described_class
  end

  describe '#route' do
    it 'provides a route to GET /' do
      expect(router.route('/')).to eql [200, 'WebFetch']
    end

    it 'provides a route to POST /fetch' do
      expect(WebFetch::Resources).to receive(:fetch).and_return('hello')
      expect(router.route('/fetch', method: 'POST')).to eql 'hello'
    end

    it 'provides a route to GET /retrieve' do
      expect(WebFetch::Resources).to receive(:retrieve).and_return('hello')
      expect(router.route('/retrieve', method: 'GET')).to eql 'hello'
    end

    it 'decodes `json` parameter and merges into request params' do
      json = { a: 10, b: [1, 2, 3] }
      expect(WebFetch::Resources).to receive(:fetch).with(json)
      router.route('/fetch',
                   method: 'POST',
                   query_string: "json=#{JSON.dump(json)}")
    end

    it 'returns appropriate response when invaid json provided' do
      result = router.route('/fetch',
                            method: 'POST',
                            query_string: "json=uh oh :(")
      expect(result).to eql [400, I18n.t(:bad_json)]
    end
  end
end
