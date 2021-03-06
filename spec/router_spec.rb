# frozen_string_literal: true

describe WebFetch::Router do
  let(:router) { described_class.new }

  it 'can be initialised' do
    expect(router).to be_a described_class
  end

  describe '#route' do
    it 'provides a route to GET /' do
      expect(router.route('/'))
        .to eql(
          status: 200, command: 'root', payload: { application: 'WebFetch' }
        )
    end

    it 'provides a route to POST /gather' do
      expect(WebFetch::Resources).to receive(:gather).and_return('hello')
      expect(router.route('/gather', method: 'POST')).to eql 'hello'
    end

    it 'provides a route to GET /retrieve' do
      expect(WebFetch::Resources).to receive(:retrieve).and_return('hello')
      expect(router.route('/retrieve/123', method: 'GET')).to eql 'hello'
    end

    it 'provides a route to GET /find' do
      expect(WebFetch::Resources).to receive(:find).and_return('hello')
      expect(router.route('/find/123', method: 'GET')).to eql 'hello'
    end

    it 'decodes `json` parameter and merges into request params' do
      json = { a: 10, b: [1, 2, 3] }
      expect(WebFetch::Resources).to receive(:gather).with(nil, json)
      router.route('/gather',
                   method: 'POST',
                   query_string: "json=#{JSON.dump(json)}",
                   server: nil)
    end

    it 'returns appropriate response when invaid json provided' do
      response = router.route('/gather',
                              method: 'POST',
                              query_string: 'json=uh oh :(',
                              server: nil)
      expect(response).to eql(status: 400, payload: I18n.t(:bad_json))
    end
  end
end
