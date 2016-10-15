describe WebFetch::Router do
  let(:router) { described_class.new }

  it 'can be initialised' do
    expect(router).to be_a described_class
  end

  describe '#route' do
    it 'provides a route to GET /' do
      expect(router.route('/')).to eql [:ok, 'WebFetch']
    end
  end
end
