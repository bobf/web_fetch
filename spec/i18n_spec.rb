describe 'Internationalisation' do
  it 'accesses translation files and generates translations' do
    # Just a quick sanity check to make sure the translation file is loaded
    expect(I18n.t(:requests_missing)).to eql '`requests` parameter missing'
  end
end
