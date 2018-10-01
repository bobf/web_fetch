# frozen_string_literal: true

RSpec.describe WebFetch::Result do
  let(:result) do
    described_class.new(
      body: 'abc123',
      headers: { 'Foo' => 'Bar' },
      status: 200,
      pending: false,
      success: true,
      uid: 'uid123'
    )
  end

  subject { result }

  it { is_expected.to be_a described_class }
  its(:body) { is_expected.to eql 'abc123' }
  its(:headers) { are_expected.to eql('Foo' => 'Bar') }
  its(:status) { is_expected.to eql 200 }
  its(:pending?) { is_expected.to be false }
  its(:complete?) { is_expected.to be true }
  its(:success?) { is_expected.to be true }
  its(:uid) { is_expected.to eql 'uid123' }
end
